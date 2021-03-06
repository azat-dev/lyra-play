//
//  AudioService.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation

public enum AudioServiceError: Error {
    
    case internalError(Error?)
    case noActiveFile
}

public protocol AudioServiceOutput {
    
    var fileId: Observable<String?> { get }
    
    var isPlaying: Observable<Bool> { get }
    
    var volume: Observable<Double> { get }
    
    var currentTime: Observable<Double> { get }
}

public protocol AudioServiceInput {

    func play(fileId: String, data: Data) async -> Result<Void, AudioServiceError>
    
    func pause() async -> Result<Void, AudioServiceError>
    
    func stop() async -> Result<Void, AudioServiceError>
    
    func seek(time: Double) async -> Result<Void, AudioServiceError>
    
    func setVolume(value: Double) async -> Result<Void, AudioServiceError>
}

public protocol AudioService: AudioServiceInput, AudioServiceOutput {
    
}
