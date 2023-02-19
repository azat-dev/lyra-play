//
//  PlayingPlayMediaUseCaseStateControllerImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public final class PlayingPlayMediaUseCaseStateControllerImplFactory: PlayingPlayMediaUseCaseStateControllerFactory {
    
    // MARK: - Properties
    
    // MARK: - Initializers
    
    public init() {
        
    }
    
    // MARK: - Methods
    
    public func make(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        delegate: PlayMediaUseCaseStateControllerDelegate
    ) -> PlayingPlayMediaUseCaseStateController {
        
        return PlayingPlayMediaUseCaseStateControllerImpl(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: delegate
        )
    }
}
