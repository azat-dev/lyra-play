//
//  PlayMediaWithTranslationsUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 09.08.2022.
//

import XCTest
import Combine
import LyraPlay
import Mockingbird

class PlayMediaWithTranslationsUseCaseTests: XCTestCase {
    
    typealias SUT = (
        useCase: PlayMediaWithTranslationsUseCase,
        playMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCase,
        playMediaUseCase: PlayMediaUseCaseMock,
        loadSubtitlesUseCase: LoadSubtitlesUseCaseMock,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCaseMock,
        pronounceTranslationsUseCase: PronounceTranslationsUseCase,
        subtitlesScheduler: LyraPlay.Scheduler
    )
    
    func createSUT() -> SUT {
        
        let loadSubtitlesUseCase = LoadSubtitlesUseCaseMock()
        
        let textToSpeechConverter = TextToSpeechConverterMock()
        let audioPlayerMock = AudioPlayerMock()
        let pronounceTranslationsUseCase = PronounceTranslationsUseCaseImpl(
            textToSpeechConverter: textToSpeechConverter,
            audioPlayer: audioPlayerMock
        )
        
        let provideTranslationsToPlayUseCase = ProvideTranslationsToPlayUseCaseMock()
        
        let subtitlesTimer = ActionTimerMockDeprecated()
        
        let subtitlesScheduler = SchedulerImpl(timer: subtitlesTimer)
        let schedulerFactory = mock(SchedulerFactory.self)
        given(schedulerFactory.create()).willReturn(subtitlesScheduler)
        
        let subtitlesIteratorFactory = SubtitlesIteratorFactoryImpl()
        let playSubtitlesUseCaseFactory = PlaySubtitlesUseCaseImplFactory(
            subtitlesIteratorFactory: subtitlesIteratorFactory,
            schedulerFactory: schedulerFactory
            
        )
        
        let playMediaUseCase = PlayMediaUseCaseMock()
        
        let playMediaWithSubtitlesUseCase = PlayMediaWithSubtitlesUseCaseImpl(
            playMediaUseCase: playMediaUseCase,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory,
            loadSubtitlesUseCase: loadSubtitlesUseCase
        )
        
        let useCase = PlayMediaWithTranslationsUseCaseImpl(
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
        sut.loadSubtitlesUseCase.willReturn = { _, _ in
            
            if let subtitles = subtitles {
                return .success(subtitles)
            }
            
            return .failure(.itemNotFound)
        }
        
        let stateSequence = self.expectSequence(expectedStateItems)
        
        let observer = stateSequence.observe(sut.useCase.state.publisher)
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
                .noActiveSession,
                .activeSession(session, .loading),
                .activeSession(session, .loadFailed),
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
                .noActiveSession,
                .activeSession(session, .loading),
                .activeSession(session, .loaded(.initial, nil)),
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
                .noActiveSession,
                .activeSession(session, .loading),
                .activeSession(session, .loaded(.initial, .init(position: nil, subtitles: subtitles))),
            ]
        )
    }
    
    func test_play__without_subtitles() async throws {
        
        let sut = createSUT()
        
        // Given
        let session = anySession()
        
        try await prepare(
            sut: sut,
            session: session,
            subtitles: nil,
            isMediaExist: true,
            expectedStateItems: [
                .noActiveSession,
                .activeSession(session, .loading),
                .activeSession(session, .loaded(.initial, nil)),
            ]
        )
        
        let controlledPublisher = sut.useCase.state.publisher
            .enumerated()
            .map { index, item -> PlayMediaWithTranslationsUseCaseState in
                
                if index == 1 {
                    Task {
                        sut.playMediaUseCase.finish()
                    }
                }
                
                return item
            }
        
        let statePromise = watch(controlledPublisher)
        
        // When
        let result = sut.useCase.play()
        
        // Then
        try AssertResultSucceded(result)
        
        statePromise.expect(
            [
                .activeSession(session, .loaded(.initial, nil)),
                .activeSession(session, .loaded(.playing, nil)),
                .activeSession(session, .loaded(.finished, nil))
            ],
            timeout: 3
        )
    }
    
    func test_play__with_subtitles_without_translations() async throws {
        
        let sut = createSUT()
        
        // Given
        let subtitles = Subtitles(
            duration: 10,
            sentences: [
                .anySentence(at: 0),
                .anySentence(at: 1),
                .anySentence(at: 2),
            ]
        )
        let session = anySession()
        
        try await prepare(
            sut: sut,
            session: session,
            subtitles: subtitles,
            isMediaExist: true,
            expectedStateItems: [
                .noActiveSession,
                .activeSession(session, .loading),
                .activeSession(session, .loaded(.initial, .init(position: nil, subtitles: subtitles)))
            ]
        )
        
        let statePromise = watch(sut.useCase.state.publisher)
        
        // When
        let result = sut.useCase.play()

        // Then
        try AssertResultSucceded(result)
        
        statePromise.expect(
            [
                .activeSession(session, .loaded(.initial, .init(position: nil, subtitles: subtitles))),
                .activeSession(session, .loaded(.playing, .init(position: nil, subtitles: subtitles))),
                .activeSession(session, .loaded(.playing, .init(position: .sentence(0), subtitles: subtitles))),
                .activeSession(session, .loaded(.playing, .init(position: .sentence(1), subtitles: subtitles))),
                .activeSession(session, .loaded(.playing, .init(position: .sentence(2), subtitles: subtitles))),
            ],
            timeout: 3
        )
    }
    
    func test_play__with_subtitles_with_translations() async throws {
        
        let sut = createSUT()
        
        // Given
        let translation1 = SubtitlesTranslationItem(
            dictionaryItemId: UUID(),
            translationId: UUID(),
            originalText: "apple",
            translatedText: "яблоко"
        )
        
        let translation2 = SubtitlesTranslationItem(
            dictionaryItemId: UUID(),
            translationId: UUID(),
            originalText: "good",
            translatedText: "хорошо"
        )
        
        
        let translations: [TranslationsToPlay] = [
            .init(
                position: .sentence(0),
                data: .groupAfterSentence(
                    items: [
                        translation1,
                        translation2
                    ]
                )
            ),
            .init(
                position: .init(sentenceIndex: 1, timeMarkIndex: 1),
                data: .single(translation: translation2)
            )
        ]
        
        sut.provideTranslationsToPlayUseCase.willReturnGetTranslationsToPlay = translations
        
        let subtitles = Subtitles(
            duration: 10,
            sentences: [
                .anySentence(at: 0),
                .anySentence(
                    at: 1,
                    timeMarks: [
                        .anyTimeMark(at: 1.1),
                        .anyTimeMark(at: 1.2),
                        .anyTimeMark(at: 1.3),
                    ]
                ),
                .anySentence(at: 2),
            ]
        )
        let session = anySession()
        
        try await prepare(
            sut: sut,
            session: session,
            subtitles: subtitles,
            isMediaExist: true,
            expectedStateItems: [
                .noActiveSession,
                .activeSession(session, .loading),
                .activeSession(session, .loaded(.initial, .init(position: nil, subtitles: subtitles))),
            ]
        )
        
        let statePromise = watch(sut.useCase.state.publisher)
        
        // When
        let result = sut.useCase.play()
        
        // Then
        try AssertResultSucceded(result)
        
        statePromise.expect(
            [
                .activeSession(session, .loaded(.initial, .init(position: nil, subtitles: subtitles))),
                .activeSession(session, .loaded(.playing, .init(position: nil, subtitles: subtitles))),
                .activeSession(session, .loaded(.playing, .init(position: .sentence(0), subtitles: subtitles))),
                .activeSession(
                    session,
                    .loaded(
                        .pronouncingTranslations(
                            data: .group(
                                translations: [translation1, translation2],
                                currentTranslationIndex: 0
                            )
                        ),
                        .init(
                            position: .sentence(0),
                            subtitles: subtitles
                        )
                    )
                ),
                .activeSession(
                    session,
                    .loaded(
                        .pronouncingTranslations(
                            data: .group(
                                translations: [translation1, translation2],
                                currentTranslationIndex: 1
                            )
                        ),
                        .init(
                            position: .sentence(0),
                            subtitles: subtitles
                        )
                    )
                ),
                .activeSession(session, .loaded(.playing, .init(position: .sentence(0), subtitles: subtitles))),
                .activeSession(session, .loaded(.playing, .init(position: .sentence(1), subtitles: subtitles))),
                .activeSession(session, .loaded(.playing, .init(position: .init(sentenceIndex: 1, timeMarkIndex: 0), subtitles: subtitles))),
                .activeSession(session, .loaded(.playing, .init(position: .init(sentenceIndex: 1, timeMarkIndex: 1), subtitles: subtitles))),
                .activeSession(
                    session,
                    .loaded(
                        .pronouncingTranslations(
                            data: .single(translation: translation2)
                        ),
                        .init(
                            position: .init(sentenceIndex: 1, timeMarkIndex: 1),
                            subtitles: subtitles
                        )
                    )
                ),
                .activeSession(session, .loaded(.playing, .init(position: .init(sentenceIndex: 1, timeMarkIndex: 1), subtitles: subtitles))),
                .activeSession(session, .loaded(.playing, .init(position: .init(sentenceIndex: 1, timeMarkIndex: 2), subtitles: subtitles))),
                .activeSession(session, .loaded(.playing, .init(position: .sentence(2), subtitles: subtitles))),
            ],
            timeout: 3
        )
    }
}

// MARK: - Mocks

final class ProvideTranslationsToPlayUseCaseMock: ProvideTranslationsToPlayUseCase {
    
    var willReturnGetTranslationsToPlay = [TranslationsToPlay]()
    
    func getTranslationsToPlay(for position: SubtitlesPosition) -> TranslationsToPlayData? {
        return willReturnGetTranslationsToPlay.first(where: { $0.position == position })?.data
    }
    
    func prepare(params: AdvancedPlayerSession) async {
    }
}
