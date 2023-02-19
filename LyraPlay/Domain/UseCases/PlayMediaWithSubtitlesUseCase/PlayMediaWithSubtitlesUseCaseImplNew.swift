//
//  PlayMediaWithSubtitlesUseCaseImplNew.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 16.02.23.
//

import Foundation
import Combine

public final class PlayMediaWithSubtitlesUseCaseImplNew: PlayMediaWithSubtitlesUseCase {

    // MARK: - Properties

    public var state: CurrentValueSubject<PlayMediaWithSubtitlesUseCaseState, Never> = .init(.noActiveSession)
    public var willChangeSubtitlesPosition = PassthroughSubject<WillChangeSubtitlesPositionData, Never>()
    
    private lazy var currentStateController: PlayMediaWithSubtitlesUseStateController = {
        return initialStateControllerFactory.make(delegate: self)
    } ()
    
    private let initialStateControllerFactory: InitialPlayMediaWithSubtitlesUseStateControllerFactory
    private let loadingStateControllerFactory: LoadingPlayMediaWithSubtitlesUseStateControllerFactory
    private let loadedStateControllerFactory: LoadedPlayMediaWithSubtitlesUseStateControllerFactory
    private let failedLoadStateControllerFactory: FailedLoadPlayMediaWithSubtitlesUseStateControllerFactory
    
    // MARK: - Initializers

    public init(
        initialStateControllerFactory: InitialPlayMediaWithSubtitlesUseStateControllerFactory,
        loadingStateControllerFactory: LoadingPlayMediaWithSubtitlesUseStateControllerFactory,
        loadedStateControllerFactory: LoadedPlayMediaWithSubtitlesUseStateControllerFactory,
        failedLoadStateControllerFactory: FailedLoadPlayMediaWithSubtitlesUseStateControllerFactory
    ) {
        self.initialStateControllerFactory = initialStateControllerFactory
        self.loadingStateControllerFactory = loadingStateControllerFactory
        self.loadedStateControllerFactory = loadedStateControllerFactory
        self.failedLoadStateControllerFactory = failedLoadStateControllerFactory
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
        fatalError()
//        return await currentStateController.load()
    }
    
    public func didLoad(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) {
        
        let controller = loadedStateControllerFactory.make(
            session: session,
            delegate: self
        )
        
        currentStateController = controller
//        state.value = .activeSession(params, .loaded(.initial, <#T##SubtitlesState?#>))
        fatalError()
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
    }
    
    public func pause(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        fatalError()
    }
    
    public func didPause(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) {
        fatalError()
    }
    
    public func play(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        fatalError()
    }
    
    public func didStartPlay(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) {
        fatalError()
    }
    
    public func stop(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        fatalError()
    }
    
    public func didStop() {
        fatalError()
    }
}
