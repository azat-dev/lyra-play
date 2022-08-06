//
//  ProvideTranslationsToPlayUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 06.08.2022.
//

import XCTest
import LyraPlay

class ProvideTranslationsToPlayUseCaseTests: XCTestCase {
    
    typealias SUT = (
        useCase: ProvideTranslationsToPlayUseCase,
        provideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCaseMock
    )
    
    func createSUT() -> SUT {
        
        let provideTranslationsForSubtitlesUseCase = ProvideTranslationsForSubtitlesUseCaseMock()
        
        let useCase = DefaultProvideTranslationsToPlayUseCase(
            provideTranslationsForSubtitlesUseCase: provideTranslationsForSubtitlesUseCase
        )
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            provideTranslationsForSubtitlesUseCase
        )
    }
    
    private func anyPlayerSession(mediaId: UUID, subtitles: Subtitles) -> AdvancedPlayerSession {
        return .init(
            mediaId: mediaId,
            nativeLanguage: "",
            learningLanguage: "",
            subtitles: subtitles
        )
    }
    
    private func anyMediaId() -> UUID {
        return .init(uuidString: "00000000-0000-0000-0000-000000000000")!
    }
    
    private func anyTranslationId() -> UUID {
        return .init(uuidString: "00000000-0000-0000-0000-000000000000")!
    }
    
    private func emptySubtitles() -> Subtitles {
        return .init(duration: 0, sentences: [])
    }
    
    private func anySubtitles(sentences: [String]) -> Subtitles {
        
        return .init(
            duration: TimeInterval(sentences.count),
            sentences: (0..<sentences.count).map {
                return .init(startTime: TimeInterval($0), text: sentences[$0], components: [])
            }
        )
    }
    
    private func anyTranslationItem(text: String, position: TranslationItemPosition? = nil, id: UUID? = nil) -> TranslationItem {
        
        return .init(
            id: id ?? anyTranslationId(),
            text: text,
            mediaId: anyMediaId(),
            timeMark: nil,
            position: position
        )
    }
    
    func anyDictionaryItem(
        originalText: String,
        lemma: String,
        translations: [TranslationItem]
    ) -> DictionaryItem {
        
        return .init(
            id: nil,
            originalText: originalText,
            lemma: lemma,
            language: "",
            translations: translations
        )
    }
    
    func test_prepare__empty_subtitles() async throws {
        
        let sut = createSUT()
        
        let mediaId = anyMediaId()
        let testOptions = anyPlayerSession(mediaId: mediaId, subtitles: emptySubtitles())
        
        let prevState = ExpectedProvideTranslationsToPlayUseCaseOutput(from: sut.useCase)
        
        await sut.useCase.prepare(params: testOptions)
        
        AssertEqualReadable(.init(from: sut.useCase), prevState)
    }
    
    func test_prepare() async throws {
        
        let sut = createSUT()
        
        let mediaId = anyMediaId()
        let testOptions = anyPlayerSession(mediaId: mediaId, subtitles: emptySubtitles())
        
        let prevState = ExpectedProvideTranslationsToPlayUseCaseOutput(from: sut.useCase)
        
        await sut.useCase.prepare(params: testOptions)
        
        AssertEqualReadable(.init(from: sut.useCase), prevState)
    }
    
    private func anySentence(at: TimeInterval, timeMarks: [Subtitles.TimeMark]? = nil, text: String) -> Subtitles.Sentence {
        
        return Subtitles.Sentence(
            startTime: at,
            duration: nil,
            text: text,
            timeMarks: timeMarks,
            components: []
        )
    }
    
    func test_getTimeOfNextEvent__subtitles_without_time_marks_inside_sentence_zero_offset() async throws {
        
        let sut = createSUT()
        
        let sentence1 = anySentence(at: 0, text: "Apple, banana, orange")
        
        let subtitles = Subtitles(duration: 10, sentences: [
            sentence1
        ])

        let orangeTranslation = SubtitlesTranslation(
            textRange: sentence1.text.range(of: "orange")!,
            translation: .init(
                dictionaryItemId: UUID(),
                translationId: UUID(),
                originalText: "orange",
                translatedText: "translated orange"
            )
        )
        
        let bananaTranslation = SubtitlesTranslation(
            textRange: sentence1.text.range(of: "banana")!,
            translation: .init(
                dictionaryItemId: UUID(),
                translationId: UUID(),
                originalText: "banana",
                translatedText: "translated banana"
            )
        )
        
        sut.provideTranslationsForSubtitlesUseCase.willReturnItems = [
            0: [
                orangeTranslation,
                bananaTranslation,
            ]
        ]
        
        let testSession = anyPlayerSession(
            mediaId: anyMediaId(),
            subtitles: subtitles
        )
        
        await sut.useCase.prepare(params: testSession)
        
        let receivedValue = sut.useCase.getTimeOfNextEvent()
        AssertEqualReadable(receivedValue, 0)
        
        let expectedOutput = ExpectedProvideTranslationsToPlayUseCaseOutput(
            lastEventTime: 10,
            currentItem: .init(
                time: 10,
                data: .groupAfterSentence(
                    items: [
                        .init(
                            dictionaryItemId: orangeTranslation.translation.dictionaryItemId,
                            translationId: orangeTranslation.translation.translationId,
                            originalText: orangeTranslation.translation.originalText,
                            translatedText: orangeTranslation.translation.translatedText
                        ),
                        .init(
                            dictionaryItemId: bananaTranslation.translation.dictionaryItemId,
                            translationId: bananaTranslation.translation.translationId,
                            originalText: bananaTranslation.translation.originalText,
                            translatedText: bananaTranslation.translation.translatedText
                        )
                    ]
                )
            )
        )
        
        AssertEqualReadable(.init(from: sut.useCase), expectedOutput)
    }
}

// MARK: - Helpers

struct ExpectedProvideTranslationsToPlayUseCaseOutput: Equatable {
    
    var lastEventTime: TimeInterval? = nil
    var currentItem: ExpectedTranslationsToPlay? = .nilValue()
    
    init(
        lastEventTime: TimeInterval? = nil,
        currentItem: ExpectedTranslationsToPlay? = .nilValue()
    ) {
        
        self.lastEventTime = lastEventTime
        self.currentItem = currentItem
    }
    
    init(from source: ProvideTranslationsToPlayUseCaseOutput?) {
        
        guard let source = source else {
            return
        }
        
        self.lastEventTime = source.lastEventTime
        
        if let currentItem = source.currentItem {
            self.currentItem = ExpectedTranslationsToPlay(from: currentItem)
        }
    }
}

struct ExpectedTranslationsToPlay: Equatable {
    
    var isNil: Bool
    var time: TimeInterval? = nil
    var data: TranslationsToPlayData? = nil
    
    init(
        time: TimeInterval? = nil,
        data: TranslationsToPlayData? = nil
    ) {
        
        self.isNil = false
        self.time = time
        self.data = data
    }
    
    private init(isNil: Bool) {
        
        self.isNil = isNil
    }
    
    init(from source: TranslationsToPlay?) {
        
        self.isNil = (source == nil)
        
        guard let source = source else {
            return
        }
        
        self.time = source.time
        self.data = source.data
    }
    
    static func nilValue() -> ExpectedTranslationsToPlay {
        return .init(isNil: true)
    }
}

// MARK: - Mocks

class ProvideTranslationsForSubtitlesUseCaseMock: ProvideTranslationsForSubtitlesUseCase {
    
    var willReturnItems = [Int: [SubtitlesTranslation]]()
    
    init() {}
    
    func getTranslations(sentenceIndex: Int) async -> [SubtitlesTranslation] {
        
        return willReturnItems[sentenceIndex, default: []]
    }
    
    func prepare(options: AdvancedPlayerSession) async {
        
    }
}
