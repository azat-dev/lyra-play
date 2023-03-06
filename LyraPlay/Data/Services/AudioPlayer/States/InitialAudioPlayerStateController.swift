//
//  InitialAudioPlayerStateBlock.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.01.23.
//

import Foundation
import AVFoundation

public class InitialAudioPlayerStateController: NSObject, AudioPlayerStateController, AVAudioPlayerDelegate {
    
    // MARK: - Properties
    
    private weak var delegate: AudioPlayerStateControllerDelegate?
    
    public let currentTime: TimeInterval = 0
    
    public let duration: TimeInterval = 0
    
    // MARK: - Initializers
    
    public init(delegate: AudioPlayerStateControllerDelegate) {
        
        self.delegate = delegate
    }
    
    // MARK: - Methods
    
    public func prepare(
        fileId: String,
        data trackData: Data
    ) -> Result<Void, AudioPlayerError> {

        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.load(fileId: fileId, data: trackData)
    }
    
    public func resume() -> Result<Void, AudioPlayerError> {
        return .failure(.noActiveFile)
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, AudioPlayerError> {
        return .failure(.noActiveFile)
    }
    
    public func pause() -> Result<Void, AudioPlayerError> {
        return .failure(.noActiveFile)
    }
    
    public func toggle() -> Result<Void, AudioPlayerError> {
        return .failure(.noActiveFile)
    }
    
    public func stop() -> Result<Void, AudioPlayerError> {
        return .failure(.noActiveFile)
    }
    
    public func setTime(_ time: TimeInterval) {
    }
}
