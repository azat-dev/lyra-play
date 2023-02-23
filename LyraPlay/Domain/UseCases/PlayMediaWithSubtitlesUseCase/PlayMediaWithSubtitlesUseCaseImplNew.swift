//
//  PlayMediaWithSubtitlesUseCaseImplNew.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 16.02.23.
//

import Foundation
import Combine

public final class PlayMediaWithSubtitlesUseCaseImplNew: PlayMediaWithSubtitlesUseCaseNew {
    
    // MARK: - Properties
    
    public var state: CurrentValueSubject<PlayMediaWithSubtitlesUseCaseStateNew, Never> = .init(.noActiveSession)
    
    public var willChangeSubtitlesPosition = PassthroughSubject<WillChangeSubtitlesPositionData, Never>()
    
    private lazy var currentStateController: PlayMediaWithSubtitlesUseStateController = {
        return InitialPlayMediaWithSubtitlesUseStateController(delegate: self)
    } ()
    
    private var observers = Set<AnyCancellable>()
    
    public weak var delegate: PlayMediaWithSubtitlesUseCaseDelegate?
    
    private let playMediaUseCaseFactory: PlayMediaUseCaseFactory
    private let loadSubtitlesUseCaseFactory: LoadSubtitlesUseCaseFactory
    private let playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory
    
    // MARK: - Initializers
    
    public init(
        playMediaUseCaseFactory: PlayMediaUseCaseFactory,
        loadSubtitlesUseCaseFactory: LoadSubtitlesUseCaseFactory,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory
    ) {
        self.playMediaUseCaseFactory = playMediaUseCaseFactory
        self.loadSubtitlesUseCaseFactory = loadSubtitlesUseCaseFactory
        self.playSubtitlesUseCaseFactory = playSubtitlesUseCaseFactory
    }
}

// MARK: - Input Methods

extension PlayMediaWithSubtitlesUseCaseImplNew: PlayMediaWithSubtitlesUseCaseInput {
    
    public func prepare(params: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        return await currentStateController.prepare(params: params)
    }
    
    public func play() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        return currentStateController.play()
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        return currentStateController.play(atTime: atTime)
    }
    
    public func pause() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        return currentStateController.pause()
    }
    
    public func stop() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        return currentStateController.stop()
    }
    
    public func togglePlay() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        return currentStateController.togglePlay()
    }
}

extension PlayMediaWithSubtitlesUseCaseImplNew: PlayMediaWithSubtitlesUseStateControllerDelegate {
    
    public func load(params: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        let controller = LoadingPlayMediaWithSubtitlesUseStateController(
            params: params,
            delegate: self,
            playMediaUseCaseFactory: playMediaUseCaseFactory,
            loadSubtitlesUseCaseFactory: loadSubtitlesUseCaseFactory,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory
        )
        
        currentStateController = controller
        state.value = .activeSession(params, .loading)
        
        return await controller.load()
    }
    
    public func didLoad(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) {
        
        let controller = LoadedPlayMediaWithSubtitlesUseStateController(
            session: session,
            delegate: self
        )
        
        currentStateController = controller
        
        state.value = .activeSession(
            session.params,
            .loaded(
                session.subtitlesState,
                .initial
            )
        )
    }
    
    public func didFailLoad(params: PlayMediaWithSubtitlesSessionParams) {
        
        let controller = FailedLoadPlayMediaWithSubtitlesUseStateController(
            delegate: self
        )
        
        currentStateController = controller
        state.value = .activeSession(params, .loadFailed)
    }
    
    public func didFinish(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) {
        
        currentStateController = FinishedPlayMediaWithSubtitlesUseStateController(
            session: session,
            delegate: self
        )
        
        state.value = .activeSession(
            session.params,
            .loaded(
                session.subtitlesState,
                .finished
            )
        )
    }
    
    public func pause(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        let controller = PausedPlayMediaWithSubtitlesUseStateController(
            session: session,
            delegate: self
        )

        return controller.run()
    }
    
    public func didPause(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) {
        
        let controller = PausedPlayMediaWithSubtitlesUseStateController(
            session: session,
            delegate: self
        )

        currentStateController = controller
        
        state.value = .activeSession(
            session.params,
            .loaded(
                session.subtitlesState,
                .paused(time: 0)
            )
        )
    }
    
    public func play(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        let controller = PlayingPlayMediaWithSubtitlesUseStateController(
            session: session,
            delegate: self
        )

        return controller.run()
    }
    
    public func didStartPlay(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) {
        
        let controller = PlayingPlayMediaWithSubtitlesUseStateController(
            session: session,
            delegate: self
        )
        
        currentStateController = controller
        
        state.value = .activeSession(
            session.params,
            .loaded(
                session.subtitlesState,
                .playing
            )
        )
    }
    
    public func stop(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        return currentStateController.stop()
    }
    
    public func didStop() {
        
        currentStateController = InitialPlayMediaWithSubtitlesUseStateController(delegate: self)
        state.value = .noActiveSession
    }
}
