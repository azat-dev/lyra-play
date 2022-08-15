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
        playMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCase,
        playMediaUseCase: PlayMediaUseCaseMock,
        loadSubtitlesUseCase: LoadSubtitlesUseCaseMock,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase,
        provideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCaseMock,
        pronounceTranslationsUseCase: PronounceTranslationsUseCase,
        subtitlesScheduler: SchedulerMock
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
        
        let playMediaUseCase = PlayMediaUseCaseMock()
        
        let playMediaWithSubtitlesUseCase = DefaultPlayMediaWithSubtitlesUseCase(
            playMediaUseCase: playMediaUseCase,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory,
            loadSubtitlesUseCase: loadSubtitlesUseCase
        )
        
        let useCase = DefaultPlayMediaWithTranslationsUseCase(
            playMediaWithSubtitlesUseCase: playMediaWithSubtitlesUseCase,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory,
            provideTranslationsToPlayUseCase: provideTranslationsToPlayUseCase,
            pronounceTranslationsUseCase: pronounceTranslationsUseCase
        )
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            playMediaWithSubtitlesUseCase,
            playMediaUseCase,
            loadSubtitlesUseCase,
            playSubtitlesUseCaseFactory,
            provideTranslationsToPlayUseCase,
            provideTranslationsForSubtitlesUseCase,
            pronounceTranslationsUseCase,
            subtitlesScheduler
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
    
    func test_prepare__media_doesnt_exist() async throws {
        
        let sut = createSUT()
        
        let session = PlayMediaWithTranslationsSession(
            mediaId: anyMediaId(),
            learningLanguage: anyLearningLanguage(),
            nativeLanguage: anyNativeLanguage()
        )
        
        let expectedStateItems: [PlayMediaWithTranslationsUseCaseState] = [
            .initial,
            .loading(session: session),
            .loadFailed(session: session)
        ]
        
        sut.playMediaUseCase.prepareWillReturn = { _ in .failure(.trackNotFound) }
        sut.loadSubtitlesUseCase.willReturn = { _, _ in .failure(.itemNotFound)}
        let stateSequence = self.expectSequence(expectedStateItems)
        
        let observer = stateSequence.observe(sut.useCase.state)
        defer { observer.cancel() }
        
        let result = await sut.useCase.prepare(session: session)
        let error = try AssertResultFailed(result)
        
        guard case .mediaFileNotFound = error else {
            
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func test_prepare__without_subtitles() async throws {
        
        let sut = createSUT()
        
        let session = PlayMediaWithTranslationsSession(
            mediaId: anyMediaId(),
            learningLanguage: anyLearningLanguage(),
            nativeLanguage: anyNativeLanguage()
        )
        
        let expectedStateItems: [PlayMediaWithTranslationsUseCaseState] = [
            .initial,
            .loading(session: session),
            .loaded(session: session, subtitlesState: nil)
        ]
        
        sut.playMediaUseCase.prepareWillReturn = { _ in .success(()) }
        sut.loadSubtitlesUseCase.willReturn = { _, _ in .failure(.itemNotFound)}
        
        let stateSequence = self.expectSequence(expectedStateItems)
        
        let observer = stateSequence.observe(sut.useCase.state)
        defer { observer.cancel() }
        
        let result = await sut.useCase.prepare(session: session)
        try AssertResultSucceded(result)
    }
    
    func test_prepare__has_all_data() async throws {
        
        let sut = createSUT()
        
        let subtitles = emptySubtitles()
        
        let session = PlayMediaWithTranslationsSession(
            mediaId: anyMediaId(),
            learningLanguage: anyLearningLanguage(),
            nativeLanguage: anyNativeLanguage()
        )
        
        let expectedStateItems: [PlayMediaWithTranslationsUseCaseState] = [
            .initial,
            .loading(session: session),
            .loaded(session: session, subtitlesState: .init(position: nil, subtitles: emptySubtitles()))
        ]
        
        sut.playMediaUseCase.prepareWillReturn = { _ in .success(()) }
        sut.loadSubtitlesUseCase.willReturn = { _, _ in .success(subtitles)}
        
        let stateSequence = self.expectSequence(expectedStateItems)
        
        let observer = stateSequence.observe(sut.useCase.state)
        defer { observer.cancel() }
        
        let result = await sut.useCase.prepare(session: session)
        try AssertResultSucceded(result)
    }
    
    //    func test_play__wit_empty_subtitles_without_offset() async throws {
    //
    //        let sut = createSUT()
    //
    //        let testMediaId = anyMediaId()
    //        let testSubtitles = emptySubtitles()
    //
    //        let session = PlayMediaWithTranslationsSession(
    //            mediaId: testMediaId,
    //            learningLanguage: anyLearningLanguage(),
    //            nativeLanguage: anyNativeLanguage()
    //        )
    //
    //        let expectedStateItems: [PlayMediaWithTranslationsUseCaseState] = [
    //            .initial,
    //            .loading(session: session),
    //            .playing(session: session, subtitlesPosition: nil),
    //            .finished(session: session)
    //        ]
    //
    //        sut.loadSubtitlesUseCase.willReturn = { _, _ in .success(testSubtitles)  }
    //        let stateSequence = self.expectSequence(expectedStateItems)
    //
    //        let finishAtIndex = 2
    //
    //        let observer = sut.useCase.state
    //            .enumerated()
    //            .map { (index, item) in
    //
    //                if index == finishAtIndex {
    //                    Task { sut.playMediaUseCase.finish() }
    //                }
    //
    //                return item
    //            }
    //            .sink { stateSequence.fulfill(with: $0) }
    //
    //        let _ = await sut.useCase.play(
    //            mediaId: testMediaId,
    //            nativeLanguage: anyNativeLanguage(),
    //            learningLanguage: anyLearningLanguage(),
    //            at: 0
    //        )
    //
    //
    //        stateSequence.wait(timeout: 5, enforceOrder: true)
    //        observer.cancel()
    //    }
    
    //    func test_play__wit_not_empty_subtitles_without_offset() async throws {
    //
    //        let sut = createSUT()
    //
    //        let testMediaId = anyMediaId()
    //
    //        let sentence1 = "apple orange"
    //        let appleRange = sentence1.range(of: "apple")!
    //
    //        let subtitles = Subtitles(
    //            duration: 10,
    //            sentences: [
    //                .init(
    //                    startTime: 0,
    //                    duration: 1,
    //                    text: sentence1,
    //                    timeMarks: [],
    //                    components: []
    //                ),
    //                .init(
    //                    startTime: 2,
    //                    duration: 1,
    //                    text: sentence1,
    //                    timeMarks: [],
    //                    components: []
    //                )
    //            ]
    //        )
    //
    //        let translationItem1 = SubtitlesTranslationItem(
    //            dictionaryItemId: UUID(),
    //            translationId: UUID(),
    //            originalText: "apple",
    //            translatedText: "яблоко"
    //        )
    //
    //        let translation1 = SubtitlesTranslation(
    //            textRange: appleRange,
    //            translation: translationItem1
    //        )
    //
    //        let expectedStateItems: [PlayMediaWithTranslationsUseCaseState] = [
    //            .initial,
    //            .playing(subtitlesPosition: .sentence(0)),
    //            .pronouncingTranslations(
    //                subtitlesPosition: .sentence(0),
    //                data: .group(
    //                    translations: [translationItem1],
    //                    currentTranslationIndex: 0
    //                )
    //            ),
    //            .playing(subtitlesPosition: .sentence(1)),
    //            .finished
    //        ]
    //
    //        sut.provideTranslationsForSubtitlesUseCase.willReturnItems = [
    //            0: [
    //                translation1
    //            ]
    //        ]
    //
    //        let stateSequence = self.expectSequence(expectedStateItems)
    //
    //        stateSequence.observe(sut.useCase.state)
    //
    //        sut.loadSubtitlesUseCase.willReturn = { _, _ in .success(subtitles) }
    //        await sut.useCase.play(
    //            mediaId: testMediaId,
    //            nativeLanguage: anyNativeLanguage(),
    //            learningLanguage: anyLearningLanguage(),
    //            at: 0
    //        )
    //
    //        stateSequence.wait(timeout: 5, enforceOrder: true)
    //    }
}
