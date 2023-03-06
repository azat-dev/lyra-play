//
//  PausedAudioPlayerStateBlock.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.01.23.
//

import Foundation
import AVFAudio

public class PausedAudioPlayerStateController: AudioPlayerStateController {
    
    // MARK: - Properties
    
    public let session: ActiveAudioPlayerStateControllerSession
    public weak var delegate: AudioPlayerStateControllerDelegate?
    
    public var currentTime: TimeInterval {
        return session.systemPlayer.currentTime
    }
    
    public var duration: TimeInterval {
        return session.systemPlayer.duration
    }
    
    // MARK: - Initializers
    
    public init(
        session: ActiveAudioPlayerStateControllerSession,
        delegate: AudioPlayerStateControllerDelegate
    ) {
        
        self.session = session
        self.delegate = delegate
    }
    
    // MARK: - Methods
    
    public func prepare(fileId: String, data: Data) -> Result<Void, AudioPlayerError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.load(fileId: fileId, data: data)
    }
    
    public func resume() -> Result<Void, AudioPlayerError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.resumePlaying(session: session)
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, AudioPlayerError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.startPlaying(atTime: atTime, session: session)
    }
    
    public func pause() -> Result<Void, AudioPlayerError> {
        return .success(())
    }
    
    public func toggle() -> Result<Void, AudioPlayerError> {
        return resume()
    }
    
    public func stop() -> Result<Void, AudioPlayerError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.stop(session: session)
    }
    
    public func setTime(_ time: TimeInterval) {
        
        session.systemPlayer.currentTime = currentTime
    }
    
    public func runPausing() -> Result<Void, AudioPlayerError> {
        
        session.systemPlayer.pause()
        session.systemPlayer.delegate = nil
        
        delegate?.didPause(withController: self)
        return .success(())
    }
}
