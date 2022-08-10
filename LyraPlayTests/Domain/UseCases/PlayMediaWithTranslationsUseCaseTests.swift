//
//  PlayMediaWithTranslationsUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 09.08.2022.
//

import XCTest
import LyraPlay

class PlayMediaWithTranslationsUseCaseTests: XCTestCase {
    
    typealias SUT = (
        useCase: PlayMediaWithTranslationsUseCase,
        loadSubtitlesUseCase: LoadSubtitlesUseCaseMock,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase,
        provideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCaseMock,
        pronounceTranslationsUseCase: PronounceTranslationsUseCase,
        subtitlesScheduler: SchedulerMock,
        translationsScheduler: SchedulerMock
    )
    
    func createSUT() -> SUT {
        
        let loadSubtitlesUseCase = LoadSubtitlesUseCaseMock()
        
        let textToSpeechConverter = TextToSpeechConverterMock()
        let audioServiceMock = AudioServiceMock()
        let pronounceTranslationsUseCase = DefaultPronounceTranslationsUseCase(
            textToSpeechConverter: textToSpeechConverter,
            audioService: audioServiceMock
        )

        let provideTranslationsForSubtitlesUseCase = ProvideTranslationsForSubtitlesUseCaseMock()

        let provideTranslationsToPlayUseCase = DefaultProvideTranslationsToPlayUseCase(
            provideTranslationsForSubtitlesUseCase: provideTranslationsForSubtitlesUseCase
        )

        let subtitlesScheduler = SchedulerMock()

        let subtitlesIteratorFactory = DefaultSubtitlesIteratorFactory()
        let playSubtitlesUseCaseFactory = DefaultPlaySubtitlesUseCaseFactory(
            subtitlesIteratorFactory: subtitlesIteratorFactory,
            scheduler: subtitlesScheduler
        )
        
        let translationsScheduler = SchedulerMock()
        
        
        let useCase = DefaultPlayMediaWithTranslationsUseCase(
            loadSubtitlesUseCase: loadSubtitlesUseCase,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory,
            provideTranslationsToPlayUseCase: provideTranslationsToPlayUseCase,
            pronounceTranslationsUseCase: pronounceTranslationsUseCase,
            translationsScheduler: translationsScheduler
        )
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            loadSubtitlesUseCase,
            playSubtitlesUseCaseFactory,
            provideTranslationsToPlayUseCase,
            provideTranslationsForSubtitlesUseCase,
            pronounceTranslationsUseCase,
            subtitlesScheduler,
            translationsScheduler
        )
    }
    
    func anyMediaId() -> UUID {
        return UUID()
    }
    
    func anyNativeLanguage() -> String {
        return "ru_RU"
    }
    
    func anyLearningLanguage() -> String {
        return "en_US"
    }
    
    func anyAt() -> TimeInterval {
        return .init()
    }
    
    func emptySubtitles() -> Subtitles {
        return .init(duration: 0, sentences: [])
    }
    
    func test_play__wit_empty_subtitles_without_offset() async throws {
        
        let sut = createSUT()
        
        let testMediaId = anyMediaId()
        let testSubtitles = emptySubtitles()
        
        let expectedStateItems: [PlayMediaWithTranslationsUseCaseState] = [
            .initial,
            .finished
        ]
        
        sut.loadSubtitlesUseCase.resolveLoad = { _, _ in .success(testSubtitles)  }
        let stateSequence = self.expectSequence(expectedStateItems)
        
        stateSequence.observe(sut.useCase.state)
        
        let _ = await sut.useCase.play(
            mediaId: testMediaId,
            nativeLanguage: anyNativeLanguage(),
            learningLanguage: anyLearningLanguage(),
            at: 0
        )
        
        stateSequence.wait(timeout: 5, enforceOrder: true)
        sut.useCase.state.remove(observer: self)
    }
    
    func test_play__wit_not_empty_subtitles_without_offset() async throws {
        
        let sut = createSUT()
        
        let testMediaId = anyMediaId()
        
        let sentence1 = "apple orange"
        let appleRange = sentence1.range(of: "apple")!
        
        let subtitles = Subtitles(
            duration: 10,
            sentences: [
                .init(
                    startTime: 0,
                    duration: 1,
                    text: sentence1,
                    timeMarks: [],
                    components: []
                )
            ]
        )
        
        let translationItem1 = SubtitlesTranslationItem(
            dictionaryItemId: UUID(),
            translationId: UUID(),
            originalText: "apple",
            translatedText: "яблоко"
        )
        
        let translation1 = SubtitlesTranslation(
            textRange: appleRange,
            translation: translationItem1
        )
        
        let expectedStateItems: [PlayMediaWithTranslationsUseCaseState] = [
            .initial,
            .playing(subtitlesPosition: .sentence(0)),
            .pronouncingTranslations(
                subtitlesPosition: .sentence(0),
                data: .group(
                    translations: [translationItem1],
                    currentTranslationIndex: 0
                )
            ),
            .playing(subtitlesPosition: .sentence(1)),
            .finished
        ]
        
        sut.provideTranslationsForSubtitlesUseCase.willReturnItems = [
            0: [
                translation1
            ]
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        
        stateSequence.observe(sut.useCase.state)
        
        sut.loadSubtitlesUseCase.resolveLoad = { _, _ in .success(subtitles) }
        await sut.useCase.play(
            mediaId: testMediaId,
            nativeLanguage: anyNativeLanguage(),
            learningLanguage: anyLearningLanguage(),
            at: 0
        )
        
        stateSequence.wait(timeout: 5, enforceOrder: true)
    }
}
