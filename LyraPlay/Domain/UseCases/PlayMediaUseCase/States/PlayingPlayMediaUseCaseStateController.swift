//
//  PlayingPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation
import Combine

public class PlayingPlayMediaUseCaseStateController: LoadedPlayMediaUseCaseStateController {

    // MARK: - Properties
    
    private var observers = Set<AnyCancellable>()
    
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
        
        audioPlayer.state.sink { [weak self] state in
        
            guard let self = self else {
                return
            }
            
            guard case .finished = state else {
                return
            }
            
            delegate.didFinish(
                mediaId: self.mediaId,
                audioPlayer: self.audioPlayer
            )
            
        }.store(in: &observers)
    }
    
    // MARK: - Methods
    
    public override func resume() -> Result<Void, PlayMediaUseCaseError> {
        
        return .success(())
    }
    
    public override func play(atTime: TimeInterval) -> Result<Void, PlayMediaUseCaseError> {
        fatalError()
    }
    
    public override func pause() -> Result<Void, PlayMediaUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.pause(
            mediaId: mediaId,
            audioPlayer: audioPlayer
        )
    }
    
    public override func togglePlay() -> Result<Void, PlayMediaUseCaseError> {
        return pause()
    }
    
    public func runResumePlaying() -> Result<Void, PlayMediaUseCaseError> {
        
        let result = audioPlayer.resume()
        
        guard case .success = result else {
            return result.mapResult()
        }
        
        delegate?.didResumePlaying(withController: self)
        return .success(())
    }
    
    public func runPlaying(atTime: TimeInterval) -> Result<Void, PlayMediaUseCaseError> {
        
        let result = audioPlayer.play(atTime: atTime)
        
        guard case .success = result else {
            return result.mapResult()
        }
        
        delegate?.didStartPlay(withController: self)
        return .success(())
    }
}
