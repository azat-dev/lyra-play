//
//  AudioPlayerService.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation

public protocol AudioPlayerServiceOutput {
}

public protocol AudioPlayerServiceInput {

    func play(mediaInfo: MediaInfo, data: Data) async -> Result<Void, Error>
    
    func pause() async -> Result<Void, Error>
    
    func stop() async -> Result<Void, Error>
    
    func seek(time: Int) async -> Result<Void, Error>
    
    func setVolume(value: Double) async -> Result<Void, Error>
}

public protocol AudioPlayerService: AudioPlayerServiceInput, AudioPlayerServiceOutput {
    
}
