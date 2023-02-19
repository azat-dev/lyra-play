//
//  LoadingPlayMediaUseCaseStateControllerImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public final class LoadingPlayMediaUseCaseStateControllerImplFactory: LoadingPlayMediaUseCaseStateControllerFactory {
    
    // MARK: - Properties
    
    private let loadTrackUseCaseFactory: LoadTrackUseCaseFactory
    private let audioPlayerFactory: AudioPlayerFactory
    
    // MARK: - Initializers
    
    public init(
        loadTrackUseCaseFactory: LoadTrackUseCaseFactory,
        audioPlayerFactory: AudioPlayerFactory
    ) {
        
        self.loadTrackUseCaseFactory = loadTrackUseCaseFactory
        self.audioPlayerFactory = audioPlayerFactory
    }
    
    // MARK: - Methods
    
    public func make(
        mediaId: UUID,
        delegate: PlayMediaUseCaseStateControllerDelegate
    ) -> LoadingPlayMediaUseCaseStateController {
        
        return LoadingPlayMediaUseCaseStateControllerImpl(
            mediaId: mediaId,
            delegate: delegate,
            loadTrackUseCaseFactory: loadTrackUseCaseFactory,
            audioPlayerFactory: audioPlayerFactory
        )
    }
}
