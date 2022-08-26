//
//  PlayMediaUseCaseFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public final class PlayMediaUseCaseFactoryImpl: PlayMediaUseCaseFactory {
    
    public init() {}
    
    public func create(
        audioPlayer: AudioPlayer,
        loadTrackUseCase: LoadTrackUseCase
    ) -> PlayMediaUseCase {
        
        return PlayMediaUseCaseImpl(
            audioPlayer: audioPlayer,
            loadTrackUseCase: loadTrackUseCase
        )
    }
}
