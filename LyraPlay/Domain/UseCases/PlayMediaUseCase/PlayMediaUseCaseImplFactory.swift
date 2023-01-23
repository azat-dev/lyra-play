//
//  PlayMediaUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation

public final class PlayMediaUseCaseImplFactory: PlayMediaUseCaseFactory {

    // MARK: - Properties

    private let audioPlayer: AudioPlayer
    private let loadTrackUseCaseFactory: LoadTrackUseCaseFactory

    // MARK: - Initializers

    public init(
        audioPlayer: AudioPlayer,
        loadTrackUseCaseFactory: LoadTrackUseCaseFactory
    ) {

        self.audioPlayer = audioPlayer
        self.loadTrackUseCaseFactory = loadTrackUseCaseFactory
    }

    // MARK: - Methods

    public func create() -> PlayMediaUseCase {

        let loadTrackUseCase = loadTrackUseCaseFactory.create()
        
        return PlayMediaUseCaseImpl(
            audioPlayer: audioPlayer,
            loadTrackUseCase: loadTrackUseCase
        )
    }
}
