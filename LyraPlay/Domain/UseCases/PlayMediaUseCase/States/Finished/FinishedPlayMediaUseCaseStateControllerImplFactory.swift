//
//  FinishedPlayMediaUseCaseStateControllerImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public final class FinishedPlayMediaUseCaseStateControllerImplFactory: FinishedPlayMediaUseCaseStateControllerFactory {
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func make(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        delegate: PlayMediaUseCaseStateControllerDelegate
    ) -> FinishedPlayMediaUseCaseStateController {
        
        return FinishedPlayMediaUseCaseStateControllerImpl(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: delegate
        )
    }
}
