//
//  PausedPlayMediaUseCaseStateControllerImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public final class PausedPlayMediaUseCaseStateControllerImplFactory: PausedPlayMediaUseCaseStateControllerFactory {
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func make(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        delegate: PlayMediaUseCaseStateControllerDelegate
    ) -> PausedPlayMediaUseCaseStateController {
        
        return PausedPlayMediaUseCaseStateControllerImpl(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: delegate
        )
    }
}
