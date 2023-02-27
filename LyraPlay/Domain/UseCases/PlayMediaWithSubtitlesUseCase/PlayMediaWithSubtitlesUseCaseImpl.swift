//
//  PlayMediaWithSubtitlesUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 16.02.23.
//

import Foundation
import Combine

public final class PlayMediaWithSubtitlesUseCaseImpl: PlayMediaWithSubtitlesUseCase {
    
    // MARK: - Properties
    
    public let state: CurrentValueSubject<PlayMediaWithSubtitlesUseCaseState, Never> = .init(.noActiveSession)
    
    public let subtitlesState = CurrentValueSubject<SubtitlesState?, Never>(nil)
    
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

extension PlayMediaWithSubtitlesUseCaseImpl: PlayMediaWithSubtitlesUseCaseInput {
    
    public func prepare(params: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        return await currentStateController.prepare(params: params)
    }
    
    public func resume() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        return currentStateController.resume()
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

extension PlayMediaWithSubtitlesUseCaseImpl: PlaySubtitlesUseCaseDelegate {
    
    public func playSubtitlesUseCaseWillChange(fromPosition: SubtitlesPosition?, toPosition: SubtitlesPosition?, stop: inout Bool) {
        
        delegate?.playMediaWithSubtitlesUseCaseWillChange(
            from: fromPosition,
            to: toPosition,
            stop: &stop
        )
    }
    
    public func playSubtitlesUseCaseDidChange(position: SubtitlesPosition?) {
        
        delegate?.playMediaWithSubtitlesUseCaseDidChange(position: position)
    }
    
    public func playSubtitlesUseCaseDidFinish() {
        
        delegate?.playMediaWithSubtitlesUseCaseDidFinish()
    }
}

extension PlayMediaWithSubtitlesUseCaseImpl: PlayMediaWithSubtitlesUseStateControllerDelegate {
    
    public func load(params: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        let controller = LoadingPlayMediaWithSubtitlesUseStateController(
            params: params,
            delegate: self,
            playMediaUseCaseFactory: playMediaUseCaseFactory,
            loadSubtitlesUseCaseFactory: loadSubtitlesUseCaseFactory,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory,
            playSubtitlesUseCaseDelegate: self
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
        state.value = .activeSession(session.params, .loaded)
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
        
        state.value = .activeSession(session.params, .finished)
    }
    
    public func pause(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        let controller = PausedPlayMediaWithSubtitlesUseStateController(
            session: session,
            delegate: self
        )

        return controller.runPausing()
    }
    
    public func didPause(controller: PausedPlayMediaWithSubtitlesUseStateController) {
        
        currentStateController = controller
        state.value = .activeSession(controller.session.params, .paused)
    }
    
    public func resumePlaying(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        let controller = PlayingPlayMediaWithSubtitlesUseStateController(
            session: session,
            delegate: self
        )

        return controller.resumeRunning()
    }
    
    public func didResumePlaying(withController controller: PlayingPlayMediaWithSubtitlesUseStateController) {
        
        currentStateController = controller
        state.value = .activeSession(controller.session.params, .playing)
    }
    
    public func play(
        atTime: TimeInterval,
        session: PlayMediaWithSubtitlesUseStateControllerActiveSession
    ) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        let controller = PlayingPlayMediaWithSubtitlesUseStateController(
            session: session,
            delegate: self
        )

        return controller.run(atTime: atTime)
    }
    
    public func didStartPlaying(withController: PlayingPlayMediaWithSubtitlesUseStateController) {
        
        currentStateController = withController
        state.value = .activeSession(withController.session.params, .playing)
    }
    
    public func stop(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        return currentStateController.stop()
    }
    
    public func didStop() {
        
        currentStateController = InitialPlayMediaWithSubtitlesUseStateController(delegate: self)
        state.value = .noActiveSession
    }
}

// MARK: - Error Mapping

extension PlayMediaUseCaseError {
    
    func map() -> PlayMediaWithSubtitlesUseCaseError {
        
        switch self {
            
        case .noActiveTrack:
            return .noActiveMedia
            
        case .trackNotFound:
            return .mediaFileNotFound
            
        case .internalError(let error):
            return .internalError(error)
        }
    }
}

extension PlayMediaWithSubtitlesUseCaseError {
    
    func map() -> PlayMediaUseCaseError {
        
        switch self {
        
        case .mediaFileNotFound:
            return .trackNotFound
            
        case .internalError(let error):
            return .internalError(error)
            
        case .noActiveMedia:
            return .noActiveTrack
        }
    }
}

// MARK: - Result Mapping

extension Result where Failure == PlayMediaUseCaseError  {
    
    func mapResult() -> Result<Success, PlayMediaWithSubtitlesUseCaseError> {
        
        guard case .success(let value) = self else {
            return .failure(self.error!.map())
        }
        
        return .success(value)
    }
}

extension Result where Failure == PlayMediaWithSubtitlesUseCaseError  {
    
    func mapResult() -> Result<Success, PlayMediaUseCaseError> {
        
        guard case .success(let value) = self else {
            return .failure(self.error!.map())
        }
        
        return .success(value)
    }
}
