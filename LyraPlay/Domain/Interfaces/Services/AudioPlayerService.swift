//
//  AudioPlayerService.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation

public struct MediaInfo {
    
    public var title: String
    public var artist: String
    public var coverImage: Data
}

public protocol AudioPlayerServiceOutput {
}

public protocol AudioPlayerServiceInput {

    func play(trackId: String, info: MediaInfo, track: Data) async -> Result<Void, Error>
    
    func pause() async -> Result<Void, Error>
    
    func stop() async -> Result<Void, Error>
    
    func seek(time: Int) async -> Result<Void, Error>
    
    func setVolume(value: Double) async -> Result<Void, Error>
}

public protocol AudioPlayerService: AudioPlayerServiceInput, AudioPlayerServiceOutput {
    
}
