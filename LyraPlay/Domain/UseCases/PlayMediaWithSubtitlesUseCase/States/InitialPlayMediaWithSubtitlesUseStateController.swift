//
//  InitialPlayMediaWithSubtitlesUseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 16.02.23.
//

import Foundation

public class InitialPlayMediaWithSubtitlesUseStateController: PlayMediaWithSubtitlesUseStateController {
    
    // MARK: - Properties
    
    private weak var delegate: PlayMediaWithSubtitlesUseStateControllerDelegate?
    
    // MARK: - Initializers
    
    public init(delegate: PlayMediaWithSubtitlesUseStateControllerDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Methods
    
    public func prepare(params: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        delegate?.loading(params: params)
        return .success(())
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
