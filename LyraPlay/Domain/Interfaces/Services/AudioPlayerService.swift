//
//  AudioPlayerService.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation

public protocol AudioPlayerService {
    
    func play(trackId: String, track: Data) async -> Result<Void, Error>
    
    func pause() async -> Result<Void, Error>
    
    func stop() async -> Result<Void, Error>
    
    func seek(time: Int) async -> Result<Void, Error>
    
    func setVolume(value: Double) async -> Result<Void, Error>
}
