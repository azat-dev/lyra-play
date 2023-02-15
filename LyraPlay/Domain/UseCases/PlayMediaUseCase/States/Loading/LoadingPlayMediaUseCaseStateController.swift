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
    
    private let mediaId: UUID
    private unowned let context: PlayMediaUseCaseStateControllerContext
    private let statesFactories: LoadingPlayMediaUseCaseStateControllerFactories
    
    // MARK: - Initializers

    public init(
        mediaId: UUID,
        context: PlayMediaUseCaseStateControllerContext,
        loadTrackUseCaseFactory: LoadTrackUseCaseFactory,
        audioPlayerFactory: AudioPlayerFactory,
        statesFactories: LoadingPlayMediaUseCaseStateControllerFactories
    ) {
        
        self.state = .loading(mediaId: mediaId)
        
        self.mediaId = mediaId
        self.context = context
        self.statesFactories = statesFactories
        
        Task {
            
            let loadTrackUseCase = loadTrackUseCaseFactory.create()
            let loadResult = await loadTrackUseCase.load(trackId: mediaId)
            
            guard case .success(let trackData) = loadResult else {
                
                let newState = statesFactories.makeFailedLoad(mediaId: mediaId, context: context)
                context.set(newState: newState)
                return
            }
            
            let audioPlayer = audioPlayerFactory.create()
            let prepareResult = audioPlayer.prepare(fileId: mediaId.uuidString, data: trackData)
            
            guard case .success = prepareResult else {
                
                let newState = statesFactories.makeFailedLoad(mediaId: mediaId, context: context)
                context.set(newState: newState)
                return
            }
            
            let newState = statesFactories.makeLoaded(
                mediaId: mediaId,
                audioPlayer: audioPlayer,
                context: context
            )
            context.set(newState: newState)
        }
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
