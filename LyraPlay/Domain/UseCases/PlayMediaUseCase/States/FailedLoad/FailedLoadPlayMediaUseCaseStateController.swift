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
    private unowned let context: PlayMediaUseCaseStateControllerContext
    private let statesFactories: FailedLoadPlayMediaUseCaseStateControllerFactories
    
    // MARK: - Initializers

    public init(
        mediaId: UUID,
        context: PlayMediaUseCaseStateControllerContext,
        statesFactories: FailedLoadPlayMediaUseCaseStateControllerFactories
    ) {
        
        self.state = .failedLoad(mediaId: mediaId)
        
        self.mediaId = mediaId
        self.context = context
        self.statesFactories = statesFactories
    }
    
    // MARK: - Methods
    
    public func prepare(mediaId: UUID) {
        
        let newState = statesFactories.makeLoading(
            mediaId: mediaId,
            context: context
        )
        context.set(newState: newState)
    }
    
    public func play() {}
    
    public func play(atTime: TimeInterval) {}
    
    public func pause() {}
    
    public func stop() {
        
        let newState = statesFactories.makeInitial(
            context: context
        )
        context.set(newState: newState)
    }
    
    public func togglePlay() {}
}
