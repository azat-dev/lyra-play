//
//  PlayMediaUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation

public final class PlayMediaUseCaseImplFactory: PlayMediaUseCaseFactory {

    // MARK: - Properties

    private let audioPlayerFactory: AudioPlayerFactory
    private let loadTrackUseCaseFactory: LoadTrackUseCaseFactory

    // MARK: - Initializers

    public init(
        audioPlayerFactory: AudioPlayerFactory,
        loadTrackUseCaseFactory: LoadTrackUseCaseFactory
    ) {

        self.audioPlayerFactory = audioPlayerFactory
        self.loadTrackUseCaseFactory = loadTrackUseCaseFactory
    }

    // MARK: - Methods

    public func create() -> PlayMediaUseCase {

        let audioPlayer = audioPlayerFactory.create()
        let loadTrackUseCase = loadTrackUseCaseFactory.create()
        
        return PlayMediaUseCaseImpl(
            audioPlayer: audioPlayer,
            loadTrackUseCase: loadTrackUseCase
        )
    }
}
