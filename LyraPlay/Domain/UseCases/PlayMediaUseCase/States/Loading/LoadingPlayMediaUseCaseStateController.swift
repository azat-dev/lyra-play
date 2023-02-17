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
    private weak var delegate: PlayMediaUseCaseStateControllerDelegate?
    
    // MARK: - Initializers

    public init(
        mediaId: UUID,
        delegate: PlayMediaUseCaseStateControllerDelegate,
        loadTrackUseCaseFactory: LoadTrackUseCaseFactory,
        audioPlayerFactory: AudioPlayerFactory
    ) {
        
        self.state = .loading(mediaId: mediaId)
        
        self.mediaId = mediaId
        self.delegate = delegate
        
        Task {
            
            let loadTrackUseCase = loadTrackUseCaseFactory.make()
            let loadResult = await loadTrackUseCase.load(trackId: mediaId)
            
            guard case .success(let trackData) = loadResult else {
                
                delegate.didFailedLoad(mediaId: mediaId)
                return
            }
            
            let audioPlayer = audioPlayerFactory.make()
            let prepareResult = audioPlayer.prepare(fileId: mediaId.uuidString, data: trackData)
            
            guard case .success = prepareResult else {
                
                delegate.didFailedLoad(mediaId: mediaId)
                return
            }
            
            delegate.didLoaded(
                mediaId: mediaId,
                audioPlayer: audioPlayer
            )
        }
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
}
