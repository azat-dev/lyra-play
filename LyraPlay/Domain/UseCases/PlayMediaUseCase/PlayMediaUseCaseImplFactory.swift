//
//  PlayMediaUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation

public final class PlayMediaUseCaseImplFactory: PlayMediaUseCaseFactory {
    
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
    
    public func make() -> PlayMediaUseCase {
        
        return PlayMediaUseCaseImpl(
            loadTrackUseCaseFactory: loadTrackUseCaseFactory,
            audioPlayerFactory: audioPlayerFactory
        )
    }
}
