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
    private let loadTrackUseCase: LoadTrackUseCase

    // MARK: - Initializers

    public init(
        audioPlayer: AudioPlayer,
        loadTrackUseCase: LoadTrackUseCase
    ) {

        self.audioPlayer = audioPlayer
        self.loadTrackUseCase = loadTrackUseCase
    }

    // MARK: - Methods

    public func create() -> PlayMediaUseCase {

        return PlayMediaUseCaseImpl(
            audioPlayer: audioPlayer,
            loadTrackUseCase: loadTrackUseCase
        )
    }
}
