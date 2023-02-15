//
//  PlayingPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation

public class PlayingPlayMediaUseCaseStateController: PlayMediaUseCaseStateController {
    
    // MARK: - Properties
    
    public var state: PlayMediaUseCaseState

    private let mediaId: UUID
    private let audioPlayer: AudioPlayer
    private unowned let context: PlayMediaUseCaseStateControllerContext
    private let statesFactories: PlayingPlayMediaUseCaseStateControllerFactories
    
    // MARK: - Initializers
    
    public init(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        context: PlayMediaUseCaseStateControllerContext,
        statesFactories: PlayingPlayMediaUseCaseStateControllerFactories
    ) {
        
        self.state = .playing(mediaId: mediaId)

        self.mediaId = mediaId
        self.audioPlayer = audioPlayer
        self.context = context
        self.statesFactories = statesFactories
    }
    
    // MARK: - Methods
    
    public func prepare(mediaId: UUID) {
        
        let newState = statesFactories.makeLoading(
            mediaId: mediaId,
            context: context
        )
        context.set(newState: newState)
    }
    
    public func play() {}
    
    public func play(atTime: TimeInterval) {}
    
    public func pause() {
        
        let newState = statesFactories.makePaused(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            context: context
        )
        context.set(newState: newState)
    }
    
    public func stop() {
        
        let _ = audioPlayer.stop()

        let newState = statesFactories.makeInitial(
            context: context
        )
        context.set(newState: newState)
    }
    
    public func togglePlay() {
        pause()
    }
}
