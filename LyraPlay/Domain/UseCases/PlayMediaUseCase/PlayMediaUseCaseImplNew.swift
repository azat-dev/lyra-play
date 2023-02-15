//
//  PlayMediaUseCaseImplNew.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation
import Combine

public class PlayMediaUseCaseImplNew: PlayMediaUseCase, PlayMediaUseCaseStateControllerContext {
    
    // MARK: - Properties
    
    private let loadTrackUseCaseFactory: LoadTrackUseCaseFactory
    private let audioPlayerFactory: AudioPlayerFactory
    
    public lazy var state: CurrentValueSubject<PlayMediaUseCaseState, Never> = {
        
        return .init(currentStateController.state)
    } ()
    
    private lazy var currentStateController: PlayMediaUseCaseStateController = {
        
        return makeInitial(context: self)
    } ()
    
    // MARK: - Initializers
    
    public init(
        loadTrackUseCaseFactory: LoadTrackUseCaseFactory,
        audioPlayerFactory: AudioPlayerFactory
    ) {
        
        self.loadTrackUseCaseFactory = loadTrackUseCaseFactory
        self.audioPlayerFactory = audioPlayerFactory
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

extension PlayMediaUseCaseImplNew:
    InitialPlayMediaUseCaseStateControllerFactories,
    LoadingPlayMediaUseCaseStateControllerFactories,
    LoadedPlayMediaUseCaseStateControllerFactories,
    FailedLoadPlayMediaUseCaseStateControllerFactories,
    PausedPlayMediaUseCaseStateControllerFactories,
    PlayingPlayMediaUseCaseStateControllerFactories,
    FinishedPlayMediaUseCaseStateControllerFactories {
    
    public func makeInitial(context: PlayMediaUseCaseStateControllerContext) -> PlayMediaUseCaseStateController {
        return InitialPlayMediaUseCaseStateController(
            context: self,
            statesFactories: self
        )
    }
    
    public func makeLoading(
        mediaId: UUID,
        context: PlayMediaUseCaseStateControllerContext
    ) -> PlayMediaUseCaseStateController {
        
        return LoadingPlayMediaUseCaseStateController(
            mediaId: mediaId,
            context: context,
            loadTrackUseCaseFactory: loadTrackUseCaseFactory,
            audioPlayerFactory: audioPlayerFactory,
            statesFactories: self
        )
    }
    
    public func makeLoaded(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        context: PlayMediaUseCaseStateControllerContext
    ) -> PlayMediaUseCaseStateController {
        
        return LoadedPlayMediaUseCaseStateController(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            context: context,
            statesFactories: self
        )
    }
    
    public func makePlaying(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        context: PlayMediaUseCaseStateControllerContext
    ) -> PlayMediaUseCaseStateController {
        
        return PlayingPlayMediaUseCaseStateController(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            context: context,
            statesFactories: self
        )
    }
    
    public func makePaused(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        context: PlayMediaUseCaseStateControllerContext
    ) -> PlayMediaUseCaseStateController {
        
        return PausedPlayMediaUseCaseStateController(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            context: context,
            statesFactories: self
        )
    }
    
    public func makeFinished(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        context: PlayMediaUseCaseStateControllerContext
    ) -> PlayMediaUseCaseStateController {
        
        return FinishedPlayMediaUseCaseStateController(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            context: context,
            statesFactories: self
        )
    }
    
    public func makeFailedLoad(
        mediaId: UUID,
        context: PlayMediaUseCaseStateControllerContext
    ) -> PlayMediaUseCaseStateController {
        
        return FailedLoadPlayMediaUseCaseStateController(
            mediaId: mediaId,
            context: context,
            statesFactories: self
        )
    }
}
