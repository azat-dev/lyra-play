//
//  AudioSession.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public enum AudioSessionError: Error {

    case internalError(Error?)
}

public protocol AudioSessionInput {

    @discardableResult
    func activate() -> Result<Void, AudioSessionError>

    @discardableResult
    func deactivate() -> Result<Void, AudioSessionError>
}

public protocol AudioSessionOutput {}

public protocol AudioSession: AudioSessionOutput, AudioSessionInput {

}
