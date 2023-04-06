//
//  PlayingAudioPlayerStateBlock.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.01.23.
//

import Foundation

public class PlayingAudioPlayerStateController: NSObject, SystemPlayerDelegate, AudioPlayerStateController {
    

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
    
    public func prepare(fileId: String, data trackData: Data) -> Result<Void, AudioPlayerError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.load(fileId: fileId, data: trackData)
    }

    public func resume() -> Result<Void, AudioPlayerError> {
        return .success(())
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, AudioPlayerError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.startPlaying(atTime: atTime, session: session)
    }
    
    public func pause() -> Result<Void, AudioPlayerError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.pause(session: session)
    }
    
    public func toggle() -> Result<Void, AudioPlayerError> {
        return pause()
    }
    
    public func audioPlayerDidFinishPlaying(player: SystemPlayer, successfully flag: Bool) {
        
        delegate?.didFinishPlaying(session: session)
    }
    
    public func stop() -> Result<Void, AudioPlayerError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.stop(session: session)
    }
    
    public func runResumePlaying() -> Result<Void, AudioPlayerError>  {
        
        session.systemPlayer.delegate = self

        guard session.systemPlayer.play() else {
            session.systemPlayer.delegate = nil
            return .failure(.internalError(nil))
        }
        
        delegate?.didResumePlaying(withController: self)
        return .success(())
    }
    
    public func setTime(_ time: TimeInterval) {
        
        session.systemPlayer.currentTime = time
    }
    
    public func runPlaying(atTime: TimeInterval) -> Result<Void, AudioPlayerError>  {
        
        session.systemPlayer.delegate = self
        
        guard
            session.systemPlayer.play(atTime: atTime)
        else {
            session.systemPlayer.delegate = nil
            return .failure(.internalError(nil))
        }
        
        delegate?.didStartPlaying(withController: self)
        return .success(())
    }
}
