//
//  LoadingPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.02.23.
//

import Foundation

public class LoadingPlayMediaUseCaseStateControllerImpl: LoadingPlayMediaUseCaseStateController {
    
    // MARK: - Properties
    
    private let mediaId: UUID
    private weak var delegate: PlayMediaUseCaseStateControllerDelegate?
    
    private let loadTrackUseCaseFactory: LoadTrackUseCaseFactory
    private let audioPlayerFactory: AudioPlayerFactory
    
    // MARK: - Initializers

    public init(
        mediaId: UUID,
        delegate: PlayMediaUseCaseStateControllerDelegate,
        loadTrackUseCaseFactory: LoadTrackUseCaseFactory,
        audioPlayerFactory: AudioPlayerFactory
    ) {
        
        self.mediaId = mediaId
        self.delegate = delegate
        
        self.loadTrackUseCaseFactory = loadTrackUseCaseFactory
        self.audioPlayerFactory = audioPlayerFactory
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
    
    public func execute() {
        
        Task {
            let loadTrackUseCase = loadTrackUseCaseFactory.make()
            let loadResult = await loadTrackUseCase.load(trackId: mediaId)
            
            guard case .success(let trackData) = loadResult else {
                
                delegate?.didFailLoad(mediaId: mediaId)
                return
            }
            
            let audioPlayer = audioPlayerFactory.make()
            let prepareResult = audioPlayer.prepare(fileId: mediaId.uuidString, data: trackData)
            
            guard case .success = prepareResult else {
                
                delegate?.didFailLoad(mediaId: mediaId)
                return
            }
            
            delegate?.didLoad(
                mediaId: mediaId,
                audioPlayer: audioPlayer
            )
        }
    }
}
