//
//  LoadingPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.02.23.
//

import Foundation

public class LoadingPlayMediaUseCaseStateController: PlayMediaUseCaseStateController {
    
    
    // MARK: - Properties
    
    public var state: PlayMediaUseCaseState
    
    private unowned let context: PlayMediaUseCaseStateControllerContext
    
    private let mediaId: UUID
    private let loadTrackUseCase: LoadTrackUseCase
    private let statesFactories: LoadingPlayMediaUseCaseStateControllerFactories
    
    // MARK: - Initializers

    public init(
        mediaId: UUID,
        context: PlayMediaUseCaseStateControllerContext,
        loadTrackUseCase: LoadTrackUseCase,
        statesFactories: LoadingPlayMediaUseCaseStateControllerFactories
    ) {
        
        self.state = .loading(mediaId: mediaId)
        
        self.mediaId = mediaId
        self.loadTrackUseCase = loadTrackUseCase
        self.context = context
        self.statesFactories = statesFactories
    }
    
    // MARK: - Methods
    
    public func prepare(mediaId: UUID) {}
    
    public func play() {}
    
    public func play(atTime: TimeInterval) {}
    
    public func pause() {}
    
    public func stop() {}
    
    public func togglePlay() {}
}
