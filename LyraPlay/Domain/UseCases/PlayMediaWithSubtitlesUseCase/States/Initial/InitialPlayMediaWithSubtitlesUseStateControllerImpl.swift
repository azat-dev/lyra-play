//
//  InitialPlayMediaWithSubtitlesUseStateControllerImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 16.02.23.
//

import Foundation

public class InitialPlayMediaWithSubtitlesUseStateControllerImpl: InitialPlayMediaWithSubtitlesUseStateController {
    
    // MARK: - Properties
    
    public weak var delegate: PlayMediaWithSubtitlesUseStateControllerDelegate?
    
    // MARK: - Initializers
    
    public init(delegate: PlayMediaWithSubtitlesUseStateControllerDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Methods
    
    public func prepare(params: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return await delegate.load(params: params)
    }
    
    public func play() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        return .success(())
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        return .success(())
    }
    
    public func pause() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        return .success(())
    }
    
    public func stop() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        return .success(())
    }
    
    public func togglePlay() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        return .success(())
    }
}