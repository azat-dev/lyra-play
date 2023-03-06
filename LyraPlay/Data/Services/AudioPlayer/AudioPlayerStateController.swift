//
//  AudioPlayerStateBlock.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.01.23.
//

import Foundation
import AVFAudio

public protocol AudioPlayerStateController {
    
    // MARK: - Properties
    
    var currentTime: TimeInterval { get }
    
    var duration: TimeInterval { get }
    
    // MARK: - Methods
    
    func prepare(fileId: String, data trackData: Data) -> Result<Void, AudioPlayerError>
    
    func resume() -> Result<Void, AudioPlayerError>
    
    func play(atTime: TimeInterval) -> Result<Void, AudioPlayerError>
    
    func pause() -> Result<Void, AudioPlayerError>
    
    func toggle() -> Result<Void, AudioPlayerError>
    
    func stop() -> Result<Void, AudioPlayerError>
    
    func setTime(_ time: TimeInterval)
}
