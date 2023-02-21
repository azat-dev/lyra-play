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
        return initialStateControllerFactory.make(delegate: self)
    } ()
    
    private let initialStateControllerFactory: InitialPlayMediaWithSubtitlesUseStateControllerFactory
    private let loadingStateControllerFactory: LoadingPlayMediaWithSubtitlesUseStateControllerFactory
    private let loadedStateControllerFactory: LoadedPlayMediaWithSubtitlesUseStateControllerFactory
    private let failedLoadStateControllerFactory: FailedLoadPlayMediaWithSubtitlesUseStateControllerFactory
    private let playingStateControllerFactory: PlayingPlayMediaWithSubtitlesUseStateControllerFactory
    private let pausedStateControllerFactory: PausedPlayMediaWithSubtitlesUseStateControllerFactory
    private let finishedStateControllerFactory: FinishedPlayMediaWithSubtitlesUseStateControllerFactory
    
    private var observers = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    public init(
        initialStateControllerFactory: InitialPlayMediaWithSubtitlesUseStateControllerFactory,
        loadingStateControllerFactory: LoadingPlayMediaWithSubtitlesUseStateControllerFactory,
        loadedStateControllerFactory: LoadedPlayMediaWithSubtitlesUseStateControllerFactory,
        failedLoadStateControllerFactory: FailedLoadPlayMediaWithSubtitlesUseStateControllerFactory,
        playingStateControllerFactory: PlayingPlayMediaWithSubtitlesUseStateControllerFactory,
        pausedStateControllerFactory: PausedPlayMediaWithSubtitlesUseStateControllerFactory,
        finishedStateControllerFactory: FinishedPlayMediaWithSubtitlesUseStateControllerFactory
    ) {
        self.initialStateControllerFactory = initialStateControllerFactory
        self.loadingStateControllerFactory = loadingStateControllerFactory
        self.loadedStateControllerFactory = loadedStateControllerFactory
        self.failedLoadStateControllerFactory = failedLoadStateControllerFactory
        self.playingStateControllerFactory = playingStateControllerFactory
        self.pausedStateControllerFactory = pausedStateControllerFactory
        self.finishedStateControllerFactory = finishedStateControllerFactory
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
        
        let controller = loadingStateControllerFactory.make(
            params: params,
            delegate: self
        )
        
        currentStateController = controller
        state.value = .activeSession(params, .loading)
        
        return await controller.load()
    }
    
    public func didLoad(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) {
        
        let controller = loadedStateControllerFactory.make(
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
        
        let controller = failedLoadStateControllerFactory.make(
            params: params,
            delegate: self
        )
        
        currentStateController = controller
        state.value = .activeSession(params, .loadFailed)
    }
    
    public func didFinish(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) {
        
        currentStateController = finishedStateControllerFactory.make(
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
        
        let controller = pausedStateControllerFactory.make(
            session: session,
            delegate: self
        )

        return controller.run()
    }
    
    public func didPause(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) {
        
        let controller = pausedStateControllerFactory.make(
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
        
        let controller = playingStateControllerFactory.make(
            session: session,
            delegate: self
        )

        return controller.run()
    }
    
    public func didStartPlay(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) {
        
        let controller = playingStateControllerFactory.make(
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
        
        currentStateController = initialStateControllerFactory.make(delegate: self)
        state.value = .noActiveSession
    }
}
