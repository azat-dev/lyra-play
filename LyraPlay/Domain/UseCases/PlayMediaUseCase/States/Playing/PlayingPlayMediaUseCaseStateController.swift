//
//  PlayingPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation
import Combine

public class PlayingPlayMediaUseCaseStateController: PlayMediaUseCaseStateController {
    
    // MARK: - Properties
    
    public var state: PlayMediaUseCaseState

    private let mediaId: UUID
    private let audioPlayer: AudioPlayer
    private unowned let context: PlayMediaUseCaseStateControllerContext
    private let statesFactories: PlayingPlayMediaUseCaseStateControllerFactories
    
    private var observers = Set<AnyCancellable>()
    
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
        
        audioPlayer.state.sink { [weak self] state in
        
            guard let self = self else {
                return
            }
            
            guard case .finished = state else {
                return
            }
            
            let newState = self.statesFactories.makeFinished(
                mediaId: self.mediaId,
                audioPlayer: self.audioPlayer,
                context: self.context
            )
            
            self.context.set(newState: newState)
            
        }.store(in: &observers)
        
        let _ = audioPlayer.play()
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
