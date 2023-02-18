//
//  PlayingPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation

public class PausedPlayMediaUseCaseStateControllerImpl: PlayingPlayMediaUseCaseStateControllerImpl, PausedPlayMediaUseCaseStateController {
    
    // MARK: - Initializers
    
    public override init(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        delegate: PlayMediaUseCaseStateControllerDelegate
    ) {
        
        super.init(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: delegate
        )
    }
    
    // MARK: - Methods
    
    public override func play() -> Result<Void, PlayMediaUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.play(
            mediaId: mediaId,
            audioPlayer: audioPlayer
        )
    }
    
    public override func play(atTime: TimeInterval) -> Result<Void, PlayMediaUseCaseError> {
        
        fatalError()
    }
    
    public override func pause() -> Result<Void, PlayMediaUseCaseError> {
        
        return .success(())
    }
    
    public override func togglePlay() -> Result<Void, PlayMediaUseCaseError> {
        return play()
    }
    
    public override func run() -> Result<Void, PlayMediaUseCaseError> {
        
        let result = audioPlayer.pause()
        
        delegate?.didPause(
            mediaId: mediaId,
            audioPlayer: audioPlayer
        )
        
        return result.mapResult()
    }
}
