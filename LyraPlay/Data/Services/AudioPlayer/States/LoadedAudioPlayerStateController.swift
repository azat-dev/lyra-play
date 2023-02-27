//
//  LoadedAudioPlayerStateBlock.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.01.23.
//

import Foundation
import AVFAudio

public class LoadedAudioPlayerStateController: NSObject, AudioPlayerStateController {
    
    // MARK: - Properties
    
    public let session: ActiveAudioPlayerStateControllerSession
    public weak var delegate: AudioPlayerStateControllerDelegate?
    
    // MARK: - Initializers
    
    public init(
        session: ActiveAudioPlayerStateControllerSession,
        delegate: AudioPlayerStateControllerDelegate
    ) {
        
        self.session = session
        self.delegate = delegate
    }
    
    // MARK: - Methods

    public func resume() -> Result<Void, AudioPlayerError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.resumePlaying(session: session)        
    }
    
    public func toggle() -> Result<Void, AudioPlayerError> {
        return play(atTime: 0)
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, AudioPlayerError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.startPlaying(atTime: atTime, session: session)
    }
    
    public func prepare(fileId: String, data: Data) -> Result<Void, AudioPlayerError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.load(fileId: fileId, data: data)
    }
    
    public func pause() -> Result<Void, AudioPlayerError> {
        return .failure(.noActiveFile)
    }
    
    public func stop() -> Result<Void, AudioPlayerError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.stop(session: session)
    }
}
