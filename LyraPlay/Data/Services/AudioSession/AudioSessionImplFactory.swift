//
//  AudioSessionImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class AudioSessionImplFactory: AudioSessionFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func create() -> AudioSession {

        return AudioSessionImpl()
    }
}
