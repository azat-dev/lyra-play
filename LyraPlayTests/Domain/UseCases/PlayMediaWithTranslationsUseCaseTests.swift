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
        provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCaseMock,
        pronounceTranslationsUseCase: PronounceTranslationsUseCase,
        subtitlesScheduler: Scheduler
    )
    
    func createSUT() -> SUT {
        
        let loadSubtitlesUseCase = LoadSubtitlesUseCaseMock()
        
        let textToSpeechConverter = TextToSpeechConverterMock()
        let audioPlayerMock = AudioPlayerMock()
        let pronounceTranslationsUseCase = DefaultPronounceTranslationsUseCase(
            textToSpeechConverter: textToSpeechConverter,
            audioPlayer: audioPlayerMock
        )
        
        let provideTranslationsToPlayUseCase = ProvideTranslationsToPlayUseCaseMock()
        
        let subtitlesTimer = ActionTimerMock()
        
        let subtitlesScheduler = DefaultScheduler(timer: subtitlesTimer)
        
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
    
    func anySession() -> PlayMediaWithTranslationsSession {
        
        .init(
            mediaId: anyMediaId(),
            learningLanguage: anyLearningLanguage(),
            nativeLanguage: anyNativeLanguage()
        )
    }
    
    func prepare(
        sut: SUT,
        session: PlayMediaWithTranslationsSession,
        subtitles: Subtitles?,
        isMediaExist: Bool,
        expectedStateItems: [PlayMediaWithTranslationsUseCaseState],
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        
        sut.playMediaUseCase.prepareWillReturn = { _ in isMediaExist ? .success(()) : .failure(.trackNotFound) }
        sut.loadSubtitlesUseCase.willReturn = { _, _ in subtitles == nil ? .failure(.itemNotFound) : .success(subtitles!)}
        let stateSequence = self.expectSequence(expectedStateItems)
        
        let observer = stateSequence.observe(sut.useCase.state)
        defer { observer.cancel() }
        
        let result = await sut.useCase.prepare(session: session)
        
        guard isMediaExist else {
            
            let error = try AssertResultFailed(result)
            guard case .mediaFileNotFound = error else {
                
                XCTFail("Wrong error type \(error)", file: file, line: line)
                return
            }
            
            return
        }
        
        try AssertResultSucceded(result)
    }
    
    func test_prepare__media_doesnt_exist() async throws {
        
        let sut = createSUT()
        
        let session = anySession()
        
        try await prepare(
            sut: sut,
            session: session,
            subtitles: nil,
            isMediaExist: false,
            expectedStateItems: [
                .initial,
                .loading(session: session),
                .loadFailed(session: session)
            ]
        )
    }
    
    func test_prepare__without_subtitles() async throws {
        
        let sut = createSUT()
        
        let session = anySession()
        
        try await prepare(
            sut: sut,
            session: session,
            subtitles: nil,
            isMediaExist: true,
            expectedStateItems: [
                .initial,
                .loading(session: session),
                .loaded(session: session, subtitlesState: nil)
            ]
        )
    }
    
    func test_prepare__has_all_data() async throws {
        
        let sut = createSUT()
        
        let session = anySession()
        
        let subtitles = emptySubtitles()
        try await prepare(
            sut: sut,
            session: session,
            subtitles: subtitles,
            isMediaExist: true,
            expectedStateItems: [
                .initial,
                .loading(session: session),
                .loaded(session: session, subtitlesState: .init(position: nil, subtitles: subtitles))
            ]
        )
    }
    
    func test_play__without_subtitles() async throws {
        
        let sut = createSUT()
        
        let session = anySession()
        
        try await prepare(
            sut: sut,
            session: session,
            subtitles: nil,
            isMediaExist: true,
            expectedStateItems: [
                .initial,
                .loading(session: session),
                .loaded(session: session, subtitlesState: nil),
            ]
        )
        
        let expectedStateItems: [PlayMediaWithTranslationsUseCaseState] = [
            .loaded(session: session, subtitlesState: nil),
            .playing(session: session, subtitlesState: nil),
            .finished(session: session)
        ]
        
        let stateSequence = expectSequence(expectedStateItems)
        let observer = sut.useCase.state
            .enumerated()
            .map { index, item in
                
                if index == 1 {
                    Task {
                        sut.playMediaUseCase.finish()
                    }
                }
                
                return item
                
            }.sink { stateSequence.fulfill(with: $0) }
        
        let result = sut.useCase.play()
        
        try AssertResultSucceded(result)
        
        stateSequence.wait(timeout: 3, enforceOrder: true)
        observer.cancel()
    }
    
    func test_play__with_subtitles_and_translations() async throws {
        
        let sut = createSUT()
        
        let session = anySession()
        
        let translationItem1 = SubtitlesTranslationItem(
            dictionaryItemId: UUID(),
            translationId: UUID(),
            originalText: "apple",
            translatedText: "яблоко"
        )
        
        sut.provideTranslationsToPlayUseCase.willReturnGetTranslationsToPlay = { position in

            switch position {
            
            case .sentence(0):
                return .init(position: position, data: .groupAfterSentence(items: [translationItem1]))
                
            case .init(sentenceIndex: 1, timeMarkIndex: 1):
                return .init(position: position, data: .single(translation: translationItem1))

            case .sentence(2):
                return .init(position: position, data: .groupAfterSentence(items: [translationItem1]))

            default:
                return nil
            }
        }
        
        let subtitles = Subtitles(
            duration: 10,
            sentences: [
                .anySentence(at: 0),
                .anySentence(at: 1, timeMarks: [
                    .anyTimeMark(at: 1.1),
                    .anyTimeMark(at: 1.2),
                    .anyTimeMark(at: 1.3),
                ]),
                .anySentence(at: 2),
            ]
        )
        
        try await prepare(
            sut: sut,
            session: session,
            subtitles: subtitles,
            isMediaExist: true,
            expectedStateItems: [
                .initial,
                .loading(session: session),
                .loaded(session: session, subtitlesState: nil),
            ]
        )
        
        
        let expectedStateItems: [PlayMediaWithTranslationsUseCaseState] = [
            .loaded(session: session, subtitlesState: .init(position: nil, subtitles: subtitles)),
            .playing(session: session, subtitlesState: .init(position: nil, subtitles: subtitles)),
            .playing(session: session, subtitlesState: .init(position: .sentence(0), subtitles: subtitles)),
            .pronouncingTranslations(
                session: session,
                subtitlesState: .init(position: .sentence(0), subtitles: subtitles),
                data: .group(translations: [translationItem1], currentTranslationIndex: 0)
            ),
            .playing(session: session, subtitlesState: .init(position: .sentence(1), subtitles: subtitles)),
            .finished(session: session)
        ]
        
        let stateSequence = expectSequence(expectedStateItems)
        let observer = sut.useCase.state
            .enumerated()
            .map { index, item in
                
                if index == 4 {
                    Task {
                        sut.playMediaUseCase.finish()
                    }
                }
                
                return item
                
            }.sink { stateSequence.fulfill(with: $0) }
        
        let result = sut.useCase.play()
        
        try AssertResultSucceded(result)
        
        stateSequence.wait(timeout: 3, enforceOrder: true)
        observer.cancel()
    }
}

// MARK: - Mocks

final class ProvideTranslationsToPlayUseCaseMock: ProvideTranslationsToPlayUseCase {
    
    typealias GetTranslationsToPlayCallback = (_ position: SubtitlesPosition) -> TranslationsToPlay?
    
    var willReturnGetTranslationsToPlay: GetTranslationsToPlayCallback = { _ in nil }
    
    func getTranslationsToPlay(for position: SubtitlesPosition) -> TranslationsToPlay? {
        return willReturnGetTranslationsToPlay(position)
    }
    
    func prepare(params: AdvancedPlayerSession) async {
    }
}
