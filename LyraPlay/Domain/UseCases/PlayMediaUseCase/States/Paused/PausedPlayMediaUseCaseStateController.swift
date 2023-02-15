//
//  PlayingPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation

public class PausedPlayMediaUseCaseStateController: PlayMediaUseCaseStateController {
    
    // MARK: - Properties
    
    public var state: PlayMediaUseCaseState

    private let mediaId: UUID
    private let audioPlayer: AudioPlayer
    private unowned let context: PlayMediaUseCaseStateControllerContext
    private let statesFactories: PausedPlayMediaUseCaseStateControllerFactories
    
    // MARK: - Initializers
    
    public init(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        context: PlayMediaUseCaseStateControllerContext,
        statesFactories: PausedPlayMediaUseCaseStateControllerFactories
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
    
    public func play() {
        
        let newState = statesFactories.makePlaying(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            context: context
        )
        context.set(newState: newState)
    }
    
    public func play(atTime: TimeInterval) {}
    
    public func pause() {}
    
    public func stop() {
        
        let _ = audioPlayer.stop()

        let newState = statesFactories.makeInitial(
            context: context
        )
        context.set(newState: newState)
    }
    
    public func togglePlay() {
        play()
    }
}
