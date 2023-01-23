//
//  AudioSession.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public enum AudioSessionMode {
    
    case mainAudio
    case promptAudio
}

public enum AudioSessionError: Error {

    case internalError(Error?)
}

public protocol AudioSessionInput: AnyObject {

    @discardableResult
    func activate() -> Result<Void, AudioSessionError>

    @discardableResult
    func deactivate() -> Result<Void, AudioSessionError>
}

public protocol AudioSessionOutput: AnyObject {}

public protocol AudioSession: AudioSessionOutput, AudioSessionInput {

}
