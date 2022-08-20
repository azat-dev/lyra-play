//
//  AudioSession.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.08.2022.
//

import Foundation

// MARK: - Interfaces

public enum AudioSessionError: Error {

    case internalError(Error?)
}

public protocol AudioSessionInput {

    @discardableResult
    func activate() -> Result<Void, AudioSessionError>

    @discardableResult
    func deactivate() -> Result<Void, AudioSessionError>
}

public protocol AudioSession: AudioSessionInput {
}
