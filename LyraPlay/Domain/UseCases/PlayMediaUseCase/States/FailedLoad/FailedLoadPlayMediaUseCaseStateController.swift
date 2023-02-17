//
//  FailedLoadPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation

public class FailedLoadPlayMediaUseCaseStateController: PlayMediaUseCaseStateController {
    
    // MARK: - Properties
    
    public var state: PlayMediaUseCaseState
    
    private let mediaId: UUID
    private weak var delegate: PlayMediaUseCaseStateControllerDelegate?
    
    // MARK: - Initializers

    public init(
        mediaId: UUID,
        context: PlayMediaUseCaseStateControllerDelegate
    ) {
        
        self.state = .failedLoad(mediaId: mediaId)
        
        self.mediaId = mediaId
        self.delegate = context
    }
    
    // MARK: - Methods
    
    public func prepare(mediaId: UUID) {
        
        delegate?.didStartLoading(mediaId: mediaId)
    }
    
    public func play() {}
    
    public func play(atTime: TimeInterval) {}
    
    public func pause() {}
    
    public func stop() {
        
        delegate?.didStop()
    }
    
    public func togglePlay() {}
}
