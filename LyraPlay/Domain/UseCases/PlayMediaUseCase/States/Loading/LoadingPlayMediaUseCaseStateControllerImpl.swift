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
    
    public func prepare(mediaId: UUID) async -> Result<Void, PlayMediaUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return await delegate.load(mediaId: mediaId)
    }
    
    public func play() -> Result<Void, PlayMediaUseCaseError> {
        
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
    
    public func load() async -> Result<Void, PlayMediaUseCaseError> {
    
        let loadTrackUseCase = loadTrackUseCaseFactory.make()
        let loadResult = await loadTrackUseCase.load(trackId: mediaId)
        
        guard case .success(let trackData) = loadResult else {
            
            delegate?.didFailLoad(mediaId: mediaId)
            return .success(())
        }
        
        let audioPlayer = audioPlayerFactory.make()
        let prepareResult = audioPlayer.prepare(fileId: mediaId.uuidString, data: trackData)
        
        guard case .success = prepareResult else {
            
            delegate?.didFailLoad(mediaId: mediaId)
            return .success(())
        }
        
        delegate?.didLoad(
            mediaId: mediaId,
            audioPlayer: audioPlayer
        )
        
        return .success(())
    }
}
