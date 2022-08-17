//
//  AudioPlayer.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.08.2022.
//

import Foundation
import Combine

public enum AudioPlayerError: Error {

    case noActiveFile
    case internalError(Error?)
    
    case waitIsInterrupted
}

public struct AudioPlayerSession: Equatable {

    public var fileId: String

    public init(fileId: String) {
        self.fileId = fileId
    }
}

public enum AudioPlayerState: Equatable {

    case initial
    case stopped
    case loaded(session: AudioPlayerSession)
    case playing(session: AudioPlayerSession)
    case paused(session: AudioPlayerSession, time: TimeInterval)
    case finished(session: AudioPlayerSession)
    
    public var session: AudioPlayerSession? {
        
        switch self {
            
        case .initial, .stopped:
            return nil

        case .playing(let session), .loaded(let session), .paused(let session, _), .finished(let session):
            return session
        }
    }
}

// MARK: - Protocols

public protocol AudioPlayerInput {

    func prepare(fileId: String, data trackData: Data) -> Result<Void, AudioPlayerError>
    
    func play() -> Result<Void, AudioPlayerError>
    
    func play(atTime: TimeInterval) -> Result<Void, AudioPlayerError>
    
    func playAndWaitForEnd() async -> Result<Void, AudioPlayerError>

    func pause() -> Result<Void, AudioPlayerError>

    func stop() -> Result<Void, AudioPlayerError>
}

public protocol AudioPlayerOutput {

    var state: CurrentValueSubject<AudioPlayerState, Never> { get }
}

public protocol AudioPlayer: AnyObject, AudioPlayerOutput, AudioPlayerInput {
}
