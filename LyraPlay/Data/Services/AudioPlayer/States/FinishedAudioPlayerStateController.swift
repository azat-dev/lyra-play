//
//  FinishedAudioPlayerStateBlock.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.01.23.
//

import Foundation
import AVFAudio

public class FinishedAudioPlayerStateController: AudioPlayerStateController {
    
    // MARK: - Properties
    
    private let session: ActiveAudioPlayerStateControllerSession
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
        
        return delegate.startPlaying(
            atTime: 0,
            session: session
        )
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, AudioPlayerError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.startPlaying(
            atTime: atTime,
            session: session
        )
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
}
