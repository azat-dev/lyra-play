//
//  LoadedPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.02.23.
//

import Foundation

public class LoadedPlayMediaUseCaseStateControllerImpl: LoadedPlayMediaUseCaseStateController {
    
    // MARK: - Properties
    
    private let mediaId: UUID
    private weak var delegate: PlayMediaUseCaseStateControllerDelegate?
    private let audioPlayer: AudioPlayer
    
    // MARK: - Initializers

    public init(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        delegate: PlayMediaUseCaseStateControllerDelegate
    ) {
        
        self.mediaId = mediaId
        self.audioPlayer = audioPlayer
        self.delegate = delegate
    }
    
    // MARK: - Methods
    
    public func prepare(mediaId: UUID) {
        
        delegate?.didStartLoading(mediaId: mediaId)
    }
    
    public func play() {
        
        delegate?.didStartPlaying(
            mediaId: mediaId,
            audioPlayer: audioPlayer
        )
    }
    
    public func play(atTime: TimeInterval) {}
    
    public func pause() {
        
        delegate?.didPause(
            mediaId: mediaId,
            audioPlayer: audioPlayer
        )
    }
    
    public func stop() {
        
        let _ = audioPlayer.stop()
        
        delegate?.didStop()
    }
    
    public func togglePlay() {
        play()
    }
    
    public func execute() {}
}
