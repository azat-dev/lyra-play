//
//  InitialPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.02.23.
//

import Foundation

public class InitialPlayMediaUseCaseStateController: PlayMediaUseCaseStateController {
    
    // MARK: - Properties
    
    private weak var delegate: PlayMediaUseCaseStateControllerDelegate?
    
    public let currentTime: TimeInterval = 0
    
    public let duration: TimeInterval = 0
    
    // MARK: - Initializers

    public init(
        delegate: PlayMediaUseCaseStateControllerDelegate
    ) {
        
        self.delegate = delegate
    }
    
    // MARK: - Methods
    
    public func prepare(mediaId: UUID) async -> Result<Void, PlayMediaUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return await delegate.load(mediaId: mediaId)
    }
    
    public func resume() -> Result<Void, PlayMediaUseCaseError> {
        return .failure(.noActiveTrack)
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaUseCaseError> {
        return .failure(.noActiveTrack)
    }
    
    public func pause() -> Result<Void, PlayMediaUseCaseError> {
        return .failure(.noActiveTrack)
    }
    
    public func stop() -> Result<Void, PlayMediaUseCaseError> {
        return .failure(.noActiveTrack)
    }
    
    public func togglePlay() -> Result<Void, PlayMediaUseCaseError> {
        return .failure(.noActiveTrack)
    }
    
    public func setTime(_ time: TimeInterval) {
    }
}
