//
//  AudioPlayerImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class AudioPlayerImplFactory: AudioPlayerFactory {

    // MARK: - Properties

    private let audioSession: AudioSession

    // MARK: - Initializers

    public init(audioSession: AudioSession) {

        self.audioSession = audioSession
    }

    // MARK: - Methods

    public func create() -> AudioPlayer {

        return AudioPlayerImpl(audioSession: audioSession)
    }
}