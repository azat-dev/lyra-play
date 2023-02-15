//
//  LoadedPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.02.23.
//

import Foundation

public class LoadedPlayMediaUseCaseStateController: PlayMediaUseCaseStateController {
    
    // MARK: - Properties
    
    public var state: PlayMediaUseCaseState
    
    private let mediaId: UUID
    private unowned let context: PlayMediaUseCaseStateControllerContext
    private let audioPlayer: AudioPlayer
    private let statesFactories: LoadedPlayMediaUseCaseStateControllerFactories
    
    // MARK: - Initializers

    public init(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        context: PlayMediaUseCaseStateControllerContext,
        statesFactories: LoadedPlayMediaUseCaseStateControllerFactories
    ) {
        
        self.state = .loaded(mediaId: mediaId)
        
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
        
        let newState = statesFactories.makeInitial(context: context)
        context.set(newState: newState)
    }
    
    public func togglePlay() {
        play()
    }
}
