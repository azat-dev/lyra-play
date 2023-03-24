//
//  LoadedPlayMediaWithSubtitlesUseStateControllerImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public class LoadedPlayMediaWithSubtitlesUseStateController: PlayMediaWithSubtitlesUseStateController {

    // MARK: - Properties
    
    public let session: PlayMediaWithSubtitlesUseStateControllerActiveSession
    public weak var delegate: PlayMediaWithSubtitlesUseStateControllerDelegate?
    
    public var currentTime: TimeInterval {
        return session.playMediaUseCase.currentTime
    }
    
    public var duration: TimeInterval {
        return session.playMediaUseCase.duration
    }
    
    // MARK: - Initializers
    
    public init(
        session: PlayMediaWithSubtitlesUseStateControllerActiveSession,
        delegate: PlayMediaWithSubtitlesUseStateControllerDelegate
    ) {
     
        self.session = session
        self.delegate = delegate
    }
    
    // MARK: - Methods
    
    public func prepare(params: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return await delegate.load(params: params)
    }
    
    public func resume() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.resumePlaying(session: session)
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.play(atTime: atTime, session: session)
    }
    
    public func pause() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        return .success(())
    }
    
    public func stop() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.stop(session: session)
    }
    
    public func togglePlay() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        return resume()
    }
    
    public func setTime(_ time: TimeInterval) {
        
        session.playMediaUseCase.setTime(time)
    }
    
    public func getPosition(for time: TimeInterval) -> SubtitlesTimeSlot? {
        
        return session.playSubtitlesUseCase?.getPosition(for: time)
    }
}
