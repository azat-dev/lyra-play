//
//  PlayingPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation
import Combine

public class PlayingPlayMediaUseCaseStateControllerImpl: LoadedPlayMediaUseCaseStateControllerImpl, PlayingPlayMediaUseCaseStateController {

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
    
    public override func play() -> Result<Void, PlayMediaUseCaseError> {
        
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
    
    public func run() -> Result<Void, PlayMediaUseCaseError> {
        
        let result = audioPlayer.play()
        
        guard case .success = result else {
            return result.mapResult()
        }
        
        delegate?.didStartPlay(
            mediaId: mediaId,
            audioPlayer: audioPlayer
        )
        
        return .success(())
    }
    
    public func run(atTime: TimeInterval) -> Result<Void, PlayMediaUseCaseError> {
        
        let result = audioPlayer.play(atTime: atTime)
        
        guard case .success = result else {
            return result.mapResult()
        }
        
        delegate?.didStartPlay(
            mediaId: mediaId,
            audioPlayer: audioPlayer
        )
        
        return .success(())
    }
}
