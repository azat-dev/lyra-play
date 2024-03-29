//
//  StoppedAudioPlayerStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.02.23.
//

import Foundation
import AVFoundation

public class StoppedAudioPlayerStateController: NSObject, AudioPlayerStateController, AVAudioPlayerDelegate {
    
    // MARK: - Properties
    
    public let session: AudioPlayerSession
    public weak var delegate: AudioPlayerStateControllerDelegate?
    
    public let currentTime: TimeInterval = 0
    public let duration: TimeInterval = 0
    
    // MARK: - Initializers
    
    public init(
        session: AudioPlayerSession,
        delegate: AudioPlayerStateControllerDelegate
    ) {
        
        self.session = session
        self.delegate = delegate
    }
    
    // MARK: - Methods
    
    public func prepare(
        fileId: String,
        data: Data
    ) -> Result<Void, AudioPlayerError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.load(fileId: fileId, data: data)
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
        return .success(())
    }
    
    public func setTime(_ time: TimeInterval) {
    }
    
    public func runStopping(activeSession session: ActiveAudioPlayerStateControllerSession)  -> Result<Void, AudioPlayerError> {
        
        session.systemPlayer.stop()
        delegate?.didStop(withController: self)
        
        return .success(())
    }
}
