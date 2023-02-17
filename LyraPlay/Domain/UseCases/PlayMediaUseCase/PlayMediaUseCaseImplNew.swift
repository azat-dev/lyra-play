//
//  PlayMediaUseCaseImplNew.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation
import Combine

public class PlayMediaUseCaseImplNew: PlayMediaUseCase, PlayMediaUseCaseStateControllerDelegate {

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

extension PlayMediaUseCaseImplNew {
    
    public func prepare(mediaId: UUID) async -> Result<Void, PlayMediaUseCaseError> {
        
        currentStateController.prepare(mediaId: mediaId)
        return .success(())
    }
    
    public func play() -> Result<Void, PlayMediaUseCaseError> {
        
        currentStateController.play()
        return .success(())
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaUseCaseError> {
        
        currentStateController.play(atTime: atTime)
        return .success(())
    }
    
    public func togglePlay() -> Result<Void, PlayMediaUseCaseError> {
        
        currentStateController.togglePlay()
        return .success(())
    }
    
    public func pause() -> Result<Void, PlayMediaUseCaseError> {
        
        currentStateController.pause()
        return .success(())
    }
    
    public func stop() -> Result<Void, PlayMediaUseCaseError> {
        
        currentStateController.stop()
        return .success(())
    }
}

// MARK: - Delegate

extension PlayMediaUseCaseImplNew {
    
    private func set(newState: PlayMediaUseCaseState, controller: PlayMediaUseCaseStateController) {
        
        currentStateController = controller
        state.value = newState
        currentStateController.execute()
    }
    
    public func didStartLoading(mediaId: UUID) {

        let newController = loadingStateFactory.make(
            mediaId: mediaId,
            delegate: self
        )
        
        set(
            newState: .loading(mediaId: mediaId),
            controller: newController
        )
    }
    
    public func didLoad(mediaId: UUID, audioPlayer: AudioPlayer) {
        
        let newController = loadedStateFactory.make(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )
        
        set(
            newState: .loaded(mediaId: mediaId),
            controller: newController
        )
    }
    
    public func didStop() {
        
        set(
            newState: .initial,
            controller: initialStateFactory.make(delegate: self)
        )
    }
    
    public func didFailLoad(mediaId: UUID) {
        
        let newController = failedLoadStateFactory.make(
            mediaId: mediaId,
            delegate: self
        )
        
        set(
            newState: .failedLoad(mediaId: mediaId),
            controller: newController
        )
    }
    
    public func didFinish(mediaId: UUID, audioPlayer: AudioPlayer) {
        
        let newController = finishedStateFactory.make(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )
        
        set(
            newState: .finished(mediaId: mediaId),
            controller: newController
        )
    }
    
    public func didPause(mediaId: UUID, audioPlayer: AudioPlayer) {
        
        let newController = pausedStateFactory.make(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )
        
        set(
            newState: .paused(mediaId: mediaId, time: 0),
            controller: newController
        )
    }
    
    public func didStartPlaying(mediaId: UUID, audioPlayer: AudioPlayer) {
        
        let newController = playingStateFactory.make(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )
        
        set(
            newState: .playing(mediaId: mediaId),
            controller: newController
        )
    }
}
