//
//  PlayMediaUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public protocol PlayMediaUseCaseFactory {
    
    func create(
        audioPlayer: AudioPlayer,
        loadTrackUseCase: LoadTrackUseCase
    ) -> PlayMediaUseCase
}
