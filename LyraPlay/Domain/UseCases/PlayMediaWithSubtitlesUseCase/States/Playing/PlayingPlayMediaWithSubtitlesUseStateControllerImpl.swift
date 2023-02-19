//
//  PlayingPlayMediaWithSubtitlesUseStateControllerImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public class PlayingPlayMediaWithSubtitlesUseStateControllerImpl: LoadedPlayMediaWithSubtitlesUseStateControllerImpl, PlayingPlayMediaWithSubtitlesUseStateController {

    // MARK: - Properties
    
    // MARK: - Initializers
    
    public override init(
        session: PlayMediaWithSubtitlesUseStateControllerActiveSession,
        delegate: PlayMediaWithSubtitlesUseStateControllerDelegate
    ) {
     
        super.init(
            session: session,
            delegate: delegate
        )
    }
    
    // MARK: - Methods
    
    public override func play() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        return .success(())
    }
    
    public override func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        fatalError()
    }
    
    public override func pause() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.pause(session: session)
    }
    
    public override func togglePlay() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        return pause()
    }
    
    public func run() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        let result = session.playMediaUseCase.play()
        
        guard case .success = result else {
            return result.mapResult()
        }
        
        session.playSubtitlesUseCase?.play()
        
        delegate?.didStartPlay(session: session)
        return .success(())
    }
}
