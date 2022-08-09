//
//  AudioService.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.08.2022.
//

import Foundation

public enum AudioServiceError: Error {

    case noActiveFile
    case internalError(Error?)
    
    case waitIsInterrupted
}

public enum AudioServiceState: Equatable {

    case initial
    case stopped
    case playing(data: AudioServiceStateData)
    case interrupted(data: AudioServiceStateData, time: TimeInterval)
    case paused(data: AudioServiceStateData, time: TimeInterval)
    case finished(data: AudioServiceStateData)
}

public struct AudioServiceStateData: Equatable {

    public var fileId: String

    public init(fileId: String) {

        self.fileId = fileId
    }
}

public protocol AudioServiceInput {

    func play(fileId: String, data: Data) async -> Result<Void, AudioServiceError>
    
    func playAndWaitForEnd(fileId: String, data: Data) async -> Result<Void, AudioServiceError>

    func pause() async -> Result<Void, AudioServiceError>

    func stop() async -> Result<Void, AudioServiceError>
}

public protocol AudioServiceOutput {

    var state: Observable<AudioServiceState> { get }
}

public protocol AudioService: AnyObject, AudioServiceOutput, AudioServiceInput {
}
