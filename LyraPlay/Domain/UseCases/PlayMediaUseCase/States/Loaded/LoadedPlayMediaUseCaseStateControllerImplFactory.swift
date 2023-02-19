//
//  LoadedPlayMediaUseCaseStateControllerImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public final class LoadedPlayMediaUseCaseStateControllerImplFactory: LoadedPlayMediaUseCaseStateControllerFactory {
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func make(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        delegate: PlayMediaUseCaseStateControllerDelegate
    ) -> LoadedPlayMediaUseCaseStateController {
        
        return LoadedPlayMediaUseCaseStateControllerImpl(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: delegate
        )
    }
}
