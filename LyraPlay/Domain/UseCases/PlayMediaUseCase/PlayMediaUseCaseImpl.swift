//
//  PlayMediaUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation
import Combine

public class PlayMediaUseCaseImpl: PlayMediaUseCase, PlayMediaUseCaseStateControllerDelegate {

    private struct CurrentState {
        
        let controller: PlayMediaUseCaseStateController
        let state: PlayMediaUseCaseState
    }
    
    // MARK: - Properties
    
    public lazy var state: CurrentValueSubject<PlayMediaUseCaseState, Never> = {
        
        .init(.initial)
    } ()
    
    private lazy var currentStateController: PlayMediaUseCaseStateController = {
        return initialStateFactory.make(delegate: self)
    } ()
    
    let initialStateFactory: InitialPlayMediaUseCaseStateControllerFactory
    let loadingStateFactory: LoadingPlayMediaUseCaseStateControllerFactory
    let loadedStateFactory: LoadedPlayMediaUseCaseStateControllerFactory
    let failedLoadStateFactory: FailedLoadPlayMediaUseCaseStateControllerFactory
    let playingStateFactory: PlayingPlayMediaUseCaseStateControllerFactory
    let pausedStateFactory: PausedPlayMediaUseCaseStateControllerFactory
    let finishedStateFactory: FinishedPlayMediaUseCaseStateControllerFactory
    
    private var observers = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    public init(
        initialStateFactory: InitialPlayMediaUseCaseStateControllerFactory,
        loadingStateFactory: LoadingPlayMediaUseCaseStateControllerFactory,
        loadedStateFactory: LoadedPlayMediaUseCaseStateControllerFactory,
        failedLoadStateFactory: FailedLoadPlayMediaUseCaseStateControllerFactory,
        playingStateFactory: PlayingPlayMediaUseCaseStateControllerFactory,
        pausedStateFactory: PausedPlayMediaUseCaseStateControllerFactory,
        finishedStateFactory: FinishedPlayMediaUseCaseStateControllerFactory
    ) {
        
        self.initialStateFactory = initialStateFactory
        self.loadingStateFactory = loadingStateFactory
        self.loadedStateFactory = loadedStateFactory
        self.failedLoadStateFactory = failedLoadStateFactory
        self.playingStateFactory = playingStateFactory
        self.pausedStateFactory = pausedStateFactory
        self.finishedStateFactory = finishedStateFactory
    }
}

// MARK: - Methods

extension PlayMediaUseCaseImpl{
    
    public func prepare(mediaId: UUID) async -> Result<Void, PlayMediaUseCaseError> {
        
        return await currentStateController.prepare(mediaId: mediaId)
    }
    
    public func play() -> Result<Void, PlayMediaUseCaseError> {
        
        return currentStateController.play()
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaUseCaseError> {
        
        return currentStateController.play(atTime: atTime)
    }
    
    public func togglePlay() -> Result<Void, PlayMediaUseCaseError> {
        
        return currentStateController.togglePlay()
    }
    
    public func pause() -> Result<Void, PlayMediaUseCaseError> {
        
        return currentStateController.pause()
    }
    
    public func stop() -> Result<Void, PlayMediaUseCaseError> {
        
        return currentStateController.stop()
    }
}

// MARK: - Delegate

extension PlayMediaUseCaseImpl {
    
    public func load(mediaId: UUID) async -> Result<Void, PlayMediaUseCaseError> {

        state.value = .loading(mediaId: mediaId)
        
        let controller = loadingStateFactory.make(
            mediaId: mediaId,
            delegate: self
        )
        
        currentStateController = controller
        return await controller.load()
    }
    
    public func didLoad(
        mediaId: UUID,
        audioPlayer: AudioPlayer
    ) {
        
        let controller = loadedStateFactory.make(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )
        
        currentStateController = controller
        state.value = .loaded(mediaId: mediaId)
    }
    
    public func stop(
        mediaId: UUID,
        audioPlayer: AudioPlayer
    ) -> Result<Void, PlayMediaUseCaseError> {
        
        return currentStateController.stop()
    }
    
    public func didStop() {
        
        currentStateController = initialStateFactory.make(delegate: self)
        state.value = .stopped
    }
    
    public func didFailLoad(mediaId: UUID) {
        
        currentStateController = failedLoadStateFactory.make(
            mediaId: mediaId,
            delegate: self
        )
        
        state.value = .failedLoad(mediaId: mediaId)
    }
    
    public func didFinish(
        mediaId: UUID,
        audioPlayer: AudioPlayer
    ) {
        
        currentStateController = finishedStateFactory.make(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )
        
        state.value = .finished(mediaId: mediaId)
    }
    
    public func pause(
        mediaId: UUID,
        audioPlayer: AudioPlayer
    ) -> Result<Void, PlayMediaUseCaseError> {

        let result = audioPlayer.pause()
        
        guard case .success = result else {
            return .failure(.internalError(nil))
        }
        
        let controller = pausedStateFactory.make(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )

        return controller.run()
    }
    
    public func didPause(
        mediaId: UUID,
        audioPlayer: AudioPlayer
    ) {
        
        let controller = pausedStateFactory.make(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )
        
        currentStateController = controller
        state.value = .paused(mediaId: mediaId, time: 0)
    }
    
    public func play(
        mediaId: UUID,
        audioPlayer: AudioPlayer
    ) -> Result<Void, PlayMediaUseCaseError> {
        
        let newController = playingStateFactory.make(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )
        
        return newController.run()
    }
    
    public func play(
        atTime: TimeInterval,
        mediaId: UUID,
        audioPlayer: AudioPlayer
    ) -> Result<Void, PlayMediaUseCaseError> {
        
        let newController = playingStateFactory.make(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )
        
        return newController.run(atTime: atTime)
    }
    
    public func didStartPlay(
        mediaId: UUID,
        audioPlayer: AudioPlayer
    ) {
        
        let newController = playingStateFactory.make(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )
        
        currentStateController = newController
        state.value = .playing(mediaId: mediaId)
    }
}

// MARK: - Error Mapping

extension AudioPlayerError {
    
    func map() -> PlayMediaUseCaseError {
        
        switch self {
            
        case .internalError(let err):
            return .internalError(err)
            
        case .noActiveFile:
            return .noActiveTrack
            
        case .waitIsInterrupted:
            return .internalError(nil)
        }
    }
}

extension LoadTrackUseCaseError {
    
    func map() -> PlayMediaUseCaseError {
        
        switch self {
            
        case .trackNotFound:
            return .trackNotFound
            
        case .internalError(let err):
            return .internalError(err)
        }
    }
}

// MARK: - Result Mapping

extension Result where Failure == AudioPlayerError  {
    
    func mapResult() -> Result<Success, PlayMediaUseCaseError> {
        
        guard case .success(let value) = self else {
            return .failure(self.error!.map())
        }
        
        return .success(value)
    }
}
