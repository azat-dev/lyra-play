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
            provideTranslationsForSubtitlesUseCase: provideTranslationsForSubtitlesUseCase,
            minNumberOfItemsToQueue: 1
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
    
    private func anyTimeMark(at: TimeInterval, duration: TimeInterval? = nil) -> Subtitles.TimeMark {
        
        let dummyRange = "a".range(of: "a")!
        
        return .init(
            startTime: at,
            duration: duration,
            range: dummyRange
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
    
    private func anySentence(at: TimeInterval, timeMarks: [Subtitles.TimeMark]? = nil, text: String = "") -> Subtitles.Sentence {
        
        return Subtitles.Sentence(
            startTime: at,
            duration: nil,
            text: text,
            timeMarks: timeMarks,
            components: []
        )
    }
    
    private func anyTranslation(textRange: Range<String.Index>? = nil) -> SubtitlesTranslation {
        
        let dummnyRange = "a".range(of: "a")!
        
        return SubtitlesTranslation(
            textRange: textRange ?? dummnyRange,
            translation: .init(
                dictionaryItemId: UUID(),
                translationId: UUID(),
                originalText: UUID().uuidString,
                translatedText: UUID().uuidString
            )
        )
    }
    
    private func test_iteration(
        from time: TimeInterval,
        subtitles: Subtitles,
        translations: [Int: [SubtitlesTranslation]],
        expectedOutputs: [ExpectedProvideTranslationsToPlayUseCaseOutput],
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        
        let sut = createSUT()
        
        sut.provideTranslationsForSubtitlesUseCase.willReturnItems = translations
        
        let testSession = anyPlayerSession(
            mediaId: anyMediaId(),
            subtitles: subtitles
        )
        
        await sut.useCase.prepare(params: testSession)
        
        var receivedOutputs = [ExpectedProvideTranslationsToPlayUseCaseOutput]()
        receivedOutputs.append(.init(from: sut.useCase))

        if time != 0 {
            
            let _ = sut.useCase.beginNextExecution(from: time)
            receivedOutputs.append(.init(from: sut.useCase))
        }
        
        while true {
            
            let nextEventTime = sut.useCase.getTimeOfNextEvent()

            guard let nextEventTime = nextEventTime else {
                break
            }

            let eventTime = sut.useCase.moveToNextEvent()
            receivedOutputs.append(.init(from: sut.useCase))
            
            XCTAssertEqual(eventTime, nextEventTime, file: file, line: line)
        }
        
        AssertEqualReadable(receivedOutputs, expectedOutputs, file: file, line: line)
    }
    
    func test_iteration__of_empty_subtitles() async throws {
        
        let subtitles = Subtitles(duration: 10, sentences: [])

        try await test_iteration(
            from: 0,
            subtitles: subtitles,
            translations: [:],
            expectedOutputs: [
                .init(
                    lastEventTime: nil,
                    currentItem: .nilValue()
                ),
            ]
        )
    }
    
    func test_iterations__subtitles_without_time_marks_inside_sentence_zero_offset() async throws {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            anySentence(at: 0),
            anySentence(at: 3),
            anySentence(at: 5)
        ])

        let translation1 = anyTranslation()
        let translation2 = anyTranslation()
        
        try await test_iteration(
            from: 0,
            subtitles: subtitles,
            translations: [
                0: [
                    translation1,
                    translation2
                ],
                2: [
                    translation1
                ]
            ],
            expectedOutputs: [
                .init(
                    lastEventTime: nil,
                    currentItem: .nilValue()
                ),
                .init(
                    lastEventTime: 3,
                    currentItem: .init(
                        time: 3,
                        data: .groupAfterSentence(
                            items: [
                                translation1.translation,
                                translation2.translation,
                            ]
                        )
                    )
                ),
                .init(
                    lastEventTime: 10,
                    currentItem: .init(
                        time: 10,
                        data: .groupAfterSentence(
                            items: [
                                translation1.translation
                            ]
                        )
                    )
                )
            ]
        )
    }
    
    func test_iterations__subtitles_with_time_mark_range_equals_to_translation_range() async throws {
    
        let markedWord = "1"
        
        let sentence1 = "0 \(markedWord) 2"
        
        let markedWordRange = sentence1.range(of: markedWord)!

        let markedWordTranslation = anyTranslation(textRange: markedWordRange)
        
        let subtitles = Subtitles(duration: 10, sentences: [
            anySentence(
                at: 0,
                timeMarks: [
                    .init(
                        startTime: 1,
                        duration: 2,
                        range: markedWordRange
                    ),
                ],
                text: sentence1
            ),
        ])

        try await test_iteration(
            from: 0,
            subtitles: subtitles,
            translations: [
                0: [
                    markedWordTranslation,
                ],
            ],
            expectedOutputs: [
                .init(
                    lastEventTime: nil,
                    currentItem: .nilValue()
                ),
                .init(
                    lastEventTime: 3,
                    currentItem: .init(
                        time: 3,
                        data: .single(translation: markedWordTranslation.translation)
                    )
                )
            ]
        )
    }
    
    func test_iterations__subtitles_with_time_mark_range_greater_than_translation_range() async throws {
    
        let markedWord = "1"
        
        let sentence1 = "0 \(markedWord) 2 3"
        
        let markedWordRange = sentence1.range(of: markedWord + " 2")!

        let markedWordTranslation = anyTranslation(textRange: markedWordRange)
        
        let subtitles = Subtitles(duration: 10, sentences: [
            anySentence(
                at: 0,
                timeMarks: [
                    .init(
                        startTime: 1,
                        duration: 2,
                        range: markedWordRange
                    ),
                ],
                text: sentence1
            ),
        ])

        try await test_iteration(
            from: 0,
            subtitles: subtitles,
            translations: [
                0: [
                    markedWordTranslation,
                ],
            ],
            expectedOutputs: [
                .init(
                    lastEventTime: nil,
                    currentItem: .nilValue()
                ),
                .init(
                    lastEventTime: 3,
                    currentItem: .init(
                        time: 3,
                        data: .single(translation: markedWordTranslation.translation)
                    )
                )
            ]
        )
    }
    
    func test_iterations__subtitles_with_time_mark_range_smaller_than_translation_range() async throws {
    
        let markedWord = "1"
        
        let sentence1 = "0 \(markedWord)1 2 3"
        
        let markedWordRange = sentence1.range(of: markedWord )!
        let translationRange = sentence1.range(of: markedWord + "1")!

        let markedWordTranslation = anyTranslation(textRange: translationRange)
        
        let subtitles = Subtitles(duration: 10, sentences: [
            anySentence(
                at: 0,
                timeMarks: [
                    .init(
                        startTime: 1,
                        duration: 2,
                        range: markedWordRange
                    ),
                ],
                text: sentence1
            ),
        ])

        try await test_iteration(
            from: 0,
            subtitles: subtitles,
            translations: [
                0: [
                    markedWordTranslation,
                ],
            ],
            expectedOutputs: [
                .init(
                    lastEventTime: nil,
                    currentItem: .nilValue()
                ),
                .init(
                    lastEventTime: 10,
                    currentItem: .init(
                        time: 10,
                        data: .groupAfterSentence(items: [markedWordTranslation.translation])
                    )
                )
            ]
        )
    }
    
    func test_iterations__subtitles_with_multiple_time_marks_inside_translation_range__use_only_last_one() async throws {
    
        let markedWord = "12"
        
        let sentence1 = "0 \(markedWord) 3 4 5"
        
        let markedWordRange = sentence1.range(of: markedWord )!
        
        let timeMarkRange1 = sentence1.range(of: "1")!
        let timeMarkRange2 = sentence1.range(of: "2")!
        
        let markedWordTranslation = anyTranslation(textRange: markedWordRange)
        
        let subtitles = Subtitles(duration: 10, sentences: [
            anySentence(
                at: 0,
                timeMarks: [
                    .init(
                        startTime: 1,
                        duration: 2,
                        range: timeMarkRange1
                    ),
                    .init(
                        startTime: 4,
                        duration: 1,
                        range: timeMarkRange2
                    ),
                ],
                text: sentence1
            ),
        ])

        try await test_iteration(
            from: 0,
            subtitles: subtitles,
            translations: [
                0: [
                    markedWordTranslation,
                ],
            ],
            expectedOutputs: [
                .init(
                    lastEventTime: nil,
                    currentItem: .nilValue()
                ),
                .init(
                    lastEventTime: 5,
                    currentItem: .init(
                        time: 5,
                        data: .single(translation: markedWordTranslation.translation)
                    )
                )
            ]
        )
    }
    
    func test_beginNextExecution__empty_subtitles() async throws {

        let subtitles = Subtitles(duration: 10, sentences: [])

        try await test_iteration(
            from: 100,
            subtitles: subtitles,
            translations: [:],
            expectedOutputs: [
                .init(
                    lastEventTime: nil,
                    currentItem: .nilValue()
                ),
                .init(
                    lastEventTime: nil,
                    currentItem: .nilValue()
                )
            ]
        )
    }
    
    func test_beginNextExecution__not_empty_subtitles_with_offset() async throws {

        let subtitles = Subtitles(duration: 10, sentences: [
            anySentence(at: 0),
            anySentence(at: 3),
            anySentence(at: 5)
        ])

        let translation1 = anyTranslation()
        let translation2 = anyTranslation()
        
        let translations = [
            0: [
                translation1,
                translation2
            ],
            2: [
                translation1
            ]
        ]
        
        try await test_iteration(
            from: 3,
            subtitles: subtitles,
            translations: translations,
            expectedOutputs: [
                .initialValue(),
                .init(
                    lastEventTime: 3,
                    currentItem: .init(
                        time: 3,
                        data: .groupAfterSentence(
                            items: [
                                translation1.translation,
                                translation2.translation,
                            ]
                        )
                    )
                ),
                .init(
                    lastEventTime: 10,
                    currentItem: .init(
                        time: 10,
                        data: .groupAfterSentence(
                            items: [
                                translation1.translation
                            ]
                        )
                    )
                )
            ]
        )
        
        try await test_iteration(
            from: 5,
            subtitles: subtitles,
            translations: translations,
            expectedOutputs: [
                .initialValue(),
                .init(
                    lastEventTime: 3,
                    currentItem: .init(
                        time: 3,
                        data: .groupAfterSentence(
                            items: [
                                translation1.translation,
                                translation2.translation,
                            ]
                        )
                    )
                ),
                .init(
                    lastEventTime: 10,
                    currentItem: .init(
                        time: 10,
                        data: .groupAfterSentence(
                            items: [
                                translation1.translation
                            ]
                        )
                    )
                )
            ]
        )
    }
}

// MARK: - Helpers

struct ExpectedProvideTranslationsToPlayUseCaseOutput: Equatable {
    
    var lastEventTime: TimeInterval? = nil
    var currentItem: ExpectedTranslationsToPlay = .nilValue()
    
    init(
        lastEventTime: TimeInterval? = nil,
        currentItem: ExpectedTranslationsToPlay = .nilValue()
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
    
    static func initialValue() -> Self {
        
        return .init(
            lastEventTime: nil,
            currentItem: .nilValue()
        )
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