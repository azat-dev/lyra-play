//
//  PlayMediaWithTranslationsUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation
import Combine

public final class PlayMediaWithTranslationsUseCaseImpl: PlayMediaWithTranslationsUseCase {

    // MARK: - Properties

    public let state = CurrentValueSubject<PlayMediaWithTranslationsUseCaseState, Never>(.noActiveSession)
    
    public let subtitlesState = CurrentValueSubject<SubtitlesState?, Never>(nil)
    
    public let pronounceTranslationsState = CurrentValueSubject<PronounceTranslationsUseCaseState, Never>(.stopped)
    
    public var currentTime: TimeInterval {
        return currentController.currentTime
    }
    
    public var duration: TimeInterval {
        return currentController.duration
    }
    
    private lazy var currentController: PlayMediaWithTranslationsUseCaseStateController = {
        
        return InitialPlayMediaWithTranslationsUseCaseStateController(delegate: self)
    } ()
    
    private let playMediaUseCaseFactory: PlayMediaWithSubtitlesUseCaseFactory
    
    private let provideTranslationsToPlayUseCaseFactory: ProvideTranslationsToPlayUseCaseFactory
    
    private let pronounceTranslationsUseCaseFactory: PronounceTranslationsUseCaseFactory
    
    private let playerState = CurrentValueSubject<PlayMediaWithTranslationsUseCasePlayerState, Never>(.initial)
    
    private var observers = Set<AnyCancellable>()
    
    private let audioSession: AudioSession
    
    public var dictionaryWords = CurrentValueSubject<[Int: [NSRange]]?, Never>(nil)
    
    private var dictionaryWordsObserver: AnyCancellable?

    // MARK: - Initializers

    public init(
        audioSession: AudioSession,
        playMediaUseCaseFactory: PlayMediaWithSubtitlesUseCaseFactory,
        provideTranslationsToPlayUseCaseFactory: ProvideTranslationsToPlayUseCaseFactory,
        pronounceTranslationsUseCaseFactory: PronounceTranslationsUseCaseFactory
        
    ) {

        self.playMediaUseCaseFactory = playMediaUseCaseFactory
        self.provideTranslationsToPlayUseCaseFactory = provideTranslationsToPlayUseCaseFactory
        self.pronounceTranslationsUseCaseFactory = pronounceTranslationsUseCaseFactory
        self.audioSession = audioSession
    }
    
    deinit {
        observers.removeAll()
        dictionaryWordsObserver = nil
    }
}

// MARK: - Input Methods

extension PlayMediaWithTranslationsUseCaseImpl {
    
    public func prepare(session: PlayMediaWithTranslationsSession) async -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return await currentController.prepare(session: session)
    }
    
    public func resume() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return currentController.resume()
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return currentController.play(atTime: atTime)
    }
    
    public func pause() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return currentController.pause()
    }
    
    public func stop() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return currentController.stop()
    }
    
    public func togglePlay() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return currentController.togglePlay()
    }
    
    public func setTime(_ time: TimeInterval) {
        
        currentController.setTime(time)
    }
    
    public func getPosition(for time: TimeInterval) -> SubtitlesTimeSlot? {
        
        return currentController.getPosition(for: time)
    }
}

// MARK: - Update state

extension PlayMediaWithTranslationsUseCaseImpl: PlayMediaWithTranslationsUseCaseStateControllerDelegate {
    
    public func load(session: PlayMediaWithTranslationsSession) async -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        let newController = LoadingPlayMediaWithTranslationsUseCaseStateController(
            session: session,
            delegate: self,
            playMediaUseCaseFactory: playMediaUseCaseFactory,
            provideTranslationsToPlayUseCaseFactory: provideTranslationsToPlayUseCaseFactory,
            pronounceTranslationsUseCaseFactory: pronounceTranslationsUseCaseFactory
        )
        
        currentController = newController
        playerState.value = .loading
        state.value = .activeSession(session, playerState)
        
        return await newController.load()
    }
    
    public func didLoad(session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession) {
        
        let newController = LoadedPlayMediaWithTranslationsUseCaseStateController(
            session: session,
            delegate: self
        )
        
        observers.removeAll()
        
        session.playMediaUseCase.subtitlesState
            .subscribe(subtitlesState)
            .store(in: &observers)
        
        session.pronounceTranslationsUseCase.state
            .subscribe(pronounceTranslationsState)
            .store(in: &observers)
        
        currentController = newController
        playerState.value = .loaded
        
        dictionaryWordsObserver = session.provideTranslationsToPlayUseCase.dictionaryWords
            .subscribe(dictionaryWords)
    }
    
    public func didFailLoad(session: PlayMediaWithTranslationsSession) {
        
        let newController = InitialPlayMediaWithTranslationsUseCaseStateController(
            delegate: self
        )
        
        currentController = newController
        playerState.value = .loadFailed
    }
    
    public func play(
        atTime: TimeInterval,
        session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession
    ) -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        let newController = PlayingPlayMediaWithTranslationsUseCaseStateController(
            session: session,
            delegate: self
        )
        
        return newController.runPlaying(atTime: atTime)
    }
    
    public func didStartPlaying(
        withController playingController: PlayingPlayMediaWithTranslationsUseCaseStateController
    ) {
        
        audioSession.activate()
        currentController = playingController
        playerState.value = .playing
    }
    
    public func resumePlaying(session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession) -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        let newController = PlayingPlayMediaWithTranslationsUseCaseStateController(
            session: session,
            delegate: self
        )
        
        return newController.runResumePlaying()
    }
    
    public func didResumePlaying(withController controller: PlayingPlayMediaWithTranslationsUseCaseStateController) {
        
        currentController = controller
        playerState.value = .playing
    }
    
    public func pronounce(
        translationData: TranslationsToPlayData,
        session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession
    ) async -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        let newController = PlayingTranslationsPlayMediaWithTranslationsUseCaseStateController(
            translations: translationData,
            session: session,
            delegate: self
        )
        
        currentController = newController
        playerState.value = .pronouncingTranslations
        
        return await newController.run()
    }
    
    public func pause(
        elapsedTime: TimeInterval,
        session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession
    ) -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        let newController = PausedPlayMediaWithTranslationsUseCaseStateController(
            elapsedTime: elapsedTime,
            session: session,
            delegate: self
        )
        
        return newController.run()
    }
    
    public func didPause(controller: PausedPlayMediaWithTranslationsUseCaseStateController) {
        
        currentController = controller
        playerState.value = .paused
    }
    
    public func stop(activeSession: PlayMediaWithTranslationsUseCaseStateControllerActiveSession) -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        let newController = InitialPlayMediaWithTranslationsUseCaseStateController(
            delegate: self
        )
        
        return newController.run(activeSession: activeSession)
    }
    
    public func stop(session: PlayMediaWithTranslationsSession) -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        let newController = InitialPlayMediaWithTranslationsUseCaseStateController(
            delegate: self
        )
        
        currentController = newController
        state.value = .noActiveSession
        
        return .success(())
    }
    
    public func didStop() {
        
        audioSession.deactivate()
        currentController = InitialPlayMediaWithTranslationsUseCaseStateController(delegate: self)
        state.value = .noActiveSession

        dictionaryWordsObserver = nil
        dictionaryWords.value = nil
    }
    
    public func didPronounce(session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession) {
        
        let _ = resumePlaying(session: session)
    }
    
    public func didFinish(session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession) {
        
        audioSession.deactivate()
        currentController = FinishedPlayMediaWithTranslationsUseCaseStateController(
            elapsedTime: 0,
            session: session,
            delegate: self
        )
        
        playerState.value = .finished
    }
}
    
// MARK: - Error Mapping

extension PlayMediaWithSubtitlesUseCaseError {
    
    func map() -> PlayMediaWithTranslationsUseCaseError {
        
        switch self {
            
        case .mediaFileNotFound:
            return .mediaFileNotFound
            
        case .internalError(let err):
            return .internalError(err)
            
        case .noActiveMedia:
            return .noActiveMedia
        }
    }
}

// MARK: - Result Mapping

extension Result where Failure == PlayMediaWithSubtitlesUseCaseError  {
    
    func mapResult() -> Result<Success, PlayMediaWithTranslationsUseCaseError> {
        
        guard case .success(let value) = self else {
            return .failure(self.error!.map())
        }
        
        return .success(value)
    }
}
