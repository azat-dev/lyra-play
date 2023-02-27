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
    
    public let pronounceTranslationsState = CurrentValueSubject<PronounceTranslationsUseCaseState?, Never>(nil)
    
    private lazy var currentController: PlayMediaWithTranslationsUseCaseStateController = {
        
        return InitialPlayMediaWithTranslationsUseCaseStateController(delegate: self)
    } ()
    
    private let playMediaUseCaseFactory: PlayMediaWithSubtitlesUseCaseFactory
    private let provideTranslationsToPlayUseCaseFactory: ProvideTranslationsToPlayUseCaseFactory
    private let pronounceTranslationsUseCaseFactory: PronounceTranslationsUseCaseFactory

    // MARK: - Initializers

    public init(
        playMediaUseCaseFactory: PlayMediaWithSubtitlesUseCaseFactory,
        provideTranslationsToPlayUseCaseFactory: ProvideTranslationsToPlayUseCaseFactory,
        pronounceTranslationsUseCaseFactory: PronounceTranslationsUseCaseFactory
        
    ) {

        self.playMediaUseCaseFactory = playMediaUseCaseFactory
        self.provideTranslationsToPlayUseCaseFactory = provideTranslationsToPlayUseCaseFactory
        self.pronounceTranslationsUseCaseFactory = pronounceTranslationsUseCaseFactory
    }
}

// MARK: - Input Methods

extension PlayMediaWithTranslationsUseCaseImpl {
    
    public func prepare(session: PlayMediaWithTranslationsSession) async -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return await currentController.prepare(session: session)
    }
    
    public func play() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return currentController.play()
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
        state.value = .activeSession(session, .loading)
        
        return await newController.load()
    }
    
    public func didLoad(session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession) {
        
        let newController = LoadedPlayMediaWithTranslationsUseCaseStateController(
            session: session,
            delegate: self
        )
        
        currentController = newController
        state.value = .activeSession(session.session, .loaded)
    }
    
    public func didFailLoad(session: PlayMediaWithTranslationsSession) {
        
        let newController = InitialPlayMediaWithTranslationsUseCaseStateController(
            delegate: self
        )
        
        currentController = newController
        state.value = .activeSession(session, .loadFailed)
    }
    
    public func play(session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession) -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        let newController = PlayingPlayMediaWithTranslationsUseCaseStateController(
            session: session,
            delegate: self
        )
        
        return newController.run()
    }
    
    public func play(
        atTime: TimeInterval,
        session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession
    ) -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        let newController = PlayingPlayMediaWithTranslationsUseCaseStateController(
            session: session,
            delegate: self
        )
        
        return newController.run()
    }
    
    public func didStartPlaying(
        withController playingController: PlayingPlayMediaWithTranslationsUseCaseStateController
    ) {
        
        let session = playingController.session
        currentController = playingController
        
        state.value = .activeSession(session.session, .playing)
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
        
        state.value = .activeSession(
            session.session,
            .pronouncingTranslations
        )

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
        state.value = .activeSession(controller.session.session, .paused)
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
        
        currentController = InitialPlayMediaWithTranslationsUseCaseStateController(delegate: self)
        state.value = .noActiveSession
    }
    
    public func didPronounce(session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession) {
        
        let _ = play(session: session)
    }
    
    public func didFinish(session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession) {
        
        currentController = FinishedPlayMediaWithTranslationsUseCaseStateController(
            elapsedTime: 0,
            session: session,
            delegate: self
        )
        
        state.value = .activeSession(session.session, .finished)
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
