//
//  PlayMediaUseCaseImplNew.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation
import Combine

public class PlayMediaUseCaseImplNew: PlayMediaUseCase, PlayMediaUseCaseStateControllerDelegate {

    // MARK: - Properties
    
    public lazy var state: CurrentValueSubject<PlayMediaUseCaseState, Never> = {
        
        return .init(currentStateController.state)
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
    
    // MARK: - Methods
    
    public func set(newState newStateController: PlayMediaUseCaseStateController) {
        
        currentStateController = newStateController
        state.value = newStateController.state
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

// MARK: - Factories

extension PlayMediaUseCaseImplNew {
    
    public func didStartLoading(mediaId: UUID) {

        let newState = loadingStateFactory.make(
            mediaId: mediaId,
            delegate: self
        )
        
        set(newState: newState)
    }
    
    public func didLoaded(mediaId: UUID, audioPlayer: AudioPlayer) {
        
        let newState = loadedStateFactory.make(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )
        
        set(newState: newState)
    }
    
    public func didStop() {
        
        let newState = initialStateFactory.make(delegate: self)
        set(newState: newState)
    }
    
    public func didFailedLoad(mediaId: UUID) {
        
        let newState = failedLoadStateFactory.make(
            mediaId: mediaId,
            delegate: self
        )
        set(newState: newState)
    }
    
    public func didFinish(mediaId: UUID, audioPlayer: AudioPlayer) {
        
        let newState = finishedStateFactory.make(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )
        
        set(newState: newState)
    }
    
    public func didPause(mediaId: UUID, audioPlayer: AudioPlayer) {
        
        let newState = pausedStateFactory.make(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )
        
        set(newState: newState)
    }
    
    public func didStartPlaying(mediaId: UUID, audioPlayer: AudioPlayer) {
        
        let newState = playingStateFactory.make(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )
        
        set(newState: newState)
    }
}
