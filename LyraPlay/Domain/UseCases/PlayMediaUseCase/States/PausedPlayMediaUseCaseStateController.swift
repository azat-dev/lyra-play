//
//  PlayingPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation

public class PausedPlayMediaUseCaseStateController: PlayMediaUseCaseStateController {
    
    // MARK: - Properties
    
    public let mediaId: UUID
    public let audioPlayer: AudioPlayer
    public weak var delegate: PlayMediaUseCaseStateControllerDelegate?
    
    public var currentTime: TimeInterval {
        return audioPlayer.currentTime
    }
    
    public var duration: TimeInterval {
        return audioPlayer.duration
    }
    
    // MARK: - Initializers
    
    public init(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        delegate: PlayMediaUseCaseStateControllerDelegate
    ) {
        
        self.mediaId = mediaId
        self.audioPlayer = audioPlayer
        self.delegate = delegate
    }
    
    // MARK: - Methods
    
    public func prepare(mediaId: UUID) async -> Result<Void, PlayMediaUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return await delegate.load(mediaId: mediaId)
    }
    
    public func stop() -> Result<Void, PlayMediaUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        
        return delegate.stop(mediaId: mediaId, audioPlayer: audioPlayer)
    }
    
    public func resume() -> Result<Void, PlayMediaUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.resumePlaying(
            mediaId: mediaId,
            audioPlayer: audioPlayer
        )
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.play(
            atTime: atTime,
            mediaId: mediaId,
            audioPlayer: audioPlayer
        )
    }
    
    public func pause() -> Result<Void, PlayMediaUseCaseError> {
        
        return .success(())
    }
    
    public func togglePlay() -> Result<Void, PlayMediaUseCaseError> {
        return resume()
    }
    
    public func runPausing() -> Result<Void, PlayMediaUseCaseError> {
        
        let result = audioPlayer.pause()
        
        delegate?.didPause(withController: self)
        return result.mapResult()
    }
}
