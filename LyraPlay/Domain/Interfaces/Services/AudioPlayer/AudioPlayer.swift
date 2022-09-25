//
//  AudioPlayer.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation
import Combine

public enum AudioPlayerError: Error {
    
    case noActiveFile
    case internalError(Error?)
    case waitIsInterrupted
}

public enum AudioPlayerState: Equatable {
    
    case initial
    case stopped
    case loaded(session: AudioPlayerSession)
    case playing(session: AudioPlayerSession)
    case paused(session: AudioPlayerSession, time: TimeInterval)
    case finished(session: AudioPlayerSession)
}

public protocol AudioPlayerInput: AnyObject {
    
    func prepare(fileId: String, data: Data) -> Result<Void, AudioPlayerError>
    
    func play() -> Result<Void, AudioPlayerError>
    
    func play(atTime: TimeInterval) -> Result<Void, AudioPlayerError>
    
    func playAndWaitForEnd() async -> Result<Void, AudioPlayerError>
    
    func playAndWaitForEnd() -> AsyncThrowingStream<AudioPlayerState, Error>
    
    func pause() -> Result<Void, AudioPlayerError>
    
    func stop() -> Result<Void, AudioPlayerError>
}

public protocol AudioPlayerOutput: AnyObject {
    
    var state: CurrentValueSubject<AudioPlayerState, Never> { get }
}

public protocol AudioPlayer: AudioPlayerOutput, AudioPlayerInput {}
