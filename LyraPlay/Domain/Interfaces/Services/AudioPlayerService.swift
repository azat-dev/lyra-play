//
//  AudioService.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation

public protocol AudioServiceOutput {
    
    var fileId: Observable<String?> { get }
    
    var isPlaying: Observable<Bool> { get }
    
    var volume: Observable<Double> { get }
    
    var currentTime: Observable<Double> { get }
}

public protocol AudioServiceInput {

    func play(fileId: String, data: Data) async -> Result<Void, Error>
    
    func pause() async -> Result<Void, Error>
    
    func stop() async -> Result<Void, Error>
    
    func seek(time: Double) async -> Result<Void, Error>
    
    func setVolume(value: Double) async -> Result<Void, Error>
}

public protocol AudioService: AudioServiceInput, AudioServiceOutput {
    
}
