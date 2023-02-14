//
//  InitialPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.02.23.
//

import Foundation

public class InitialPlayMediaUseCaseStateController: PlayMediaUseCaseStateController {
    
    
    // MARK: - Properties
    
    public var state: PlayMediaUseCaseState
    
    private unowned let context: PlayMediaUseCaseStateControllerContext
    
    private let statesFactories: InitialPlayMediaUseCaseStateControllerFactories
    
    // MARK: - Initializers

    public init(
        context: PlayMediaUseCaseStateControllerContext,
        statesFactories: InitialPlayMediaUseCaseStateControllerFactories
    ) {
        
        self.state = .initial
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
    
    public func stop() {}
    
    public func togglePlay() {}
}
