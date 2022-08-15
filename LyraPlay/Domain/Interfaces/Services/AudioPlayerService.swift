//
//  AudioService.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.08.2022.
//

import Foundation
import Combine

public enum AudioServiceError: Error {

    case noActiveFile
    case internalError(Error?)
    
    case waitIsInterrupted
}

public struct AudioServiceSession: Equatable {

    public var fileId: String

    public init(fileId: String) {
        self.fileId = fileId
    }
}

public enum AudioServiceState: Equatable {

    case initial
    case stopped
    case loaded(session: AudioServiceSession)
    case playing(session: AudioServiceSession)
    case interrupted(session: AudioServiceSession, time: TimeInterval)
    case paused(session: AudioServiceSession, time: TimeInterval)
    case finished(session: AudioServiceSession)
    
    public var session: AudioServiceSession? {
        
        switch self {
            
        case .initial, .stopped:
            return nil

        case .playing(let session), .loaded(let session), .interrupted(let session, _), .paused(let session, _), .finished(let session):
            return session
        }
    }
}

// MARK: - Protocols

public protocol AudioServiceInput {

    func prepare(fileId: String, data trackData: Data) async -> Result<Void, AudioServiceError>
    
    func play() async -> Result<Void, AudioServiceError>
    
    func play(atTime: TimeInterval) async -> Result<Void, AudioServiceError>
    
    func playAndWaitForEnd() async -> Result<Void, AudioServiceError>

    func pause() async -> Result<Void, AudioServiceError>

    func stop() async -> Result<Void, AudioServiceError>
}

public protocol AudioServiceOutput {

    var state: CurrentValueSubject<AudioServiceState, Never> { get }
}

public protocol AudioService: AnyObject, AudioServiceOutput, AudioServiceInput {
}
