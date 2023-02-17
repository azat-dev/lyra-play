//
//  InitialPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.02.23.
//

import Foundation

public class InitialPlayMediaUseCaseStateControllerImpl: InitialPlayMediaUseCaseStateController {
    
    
    // MARK: - Properties
    
    private weak var delegate: PlayMediaUseCaseStateControllerDelegate?
    
    // MARK: - Initializers

    public init(
        delegate: PlayMediaUseCaseStateControllerDelegate
    ) {
        
        self.delegate = delegate
    }
    
    // MARK: - Methods
    
    public func prepare(mediaId: UUID) {
        
        delegate?.didStartLoading(mediaId: mediaId)
    }
    
    public func play() {}
    
    public func play(atTime: TimeInterval) {}
    
    public func pause() {}
    
    public func stop() {}
    
    public func togglePlay() {}
    
    public func execute() {}
}
