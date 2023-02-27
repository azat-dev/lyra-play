//
//  PlayingPlayMediaWithSubtitlesUseStateControllerImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation
import Combine

public class PlayingPlayMediaWithSubtitlesUseStateController: LoadedPlayMediaWithSubtitlesUseStateController {

    // MARK: - Properties
    
    private var observers = Set<AnyCancellable>()

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
    
    deinit {
        observers.removeAll()
    }
    
    // MARK: - Methods
    
    public override func resume() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        return .success(())
    }
    
    public override func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.play(atTime: atTime, session: session)
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
    
    private func startWatchingPlayingState() {
        
        session.playMediaUseCase.state
            .sink { [weak self] newState in
                
                guard
                    let self = self,
                    case .finished = newState
                else {
                    return
                }
                
                self.session.playSubtitlesUseCase?.pause()
                self.delegate?.didFinish(session: self.session)
                
            }.store(in: &observers)
    }
    
    public func run(atTime: TimeInterval) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        startWatchingPlayingState()
        let result = session.playMediaUseCase.play(atTime: 0)
        
        guard case .success = result else {
            return result.mapResult()
        }
        
        session.playSubtitlesUseCase?.play(atTime: 0)
        delegate?.didStartPlaying(withController: self)
        
        return .success(())
    }
    
    public func resumeRunning() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        startWatchingPlayingState()
        let result = session.playMediaUseCase.resume()
        
        guard case .success = result else {
            return result.mapResult()
        }
        
        session.playSubtitlesUseCase?.resume()
        delegate?.didResumePlaying(withController: self)
        
        return .success(())
    }
}
