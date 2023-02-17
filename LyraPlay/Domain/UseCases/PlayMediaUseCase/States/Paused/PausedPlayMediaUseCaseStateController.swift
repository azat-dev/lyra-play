//
//  PlayingPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation

public class PausedPlayMediaUseCaseStateController: PlayMediaUseCaseStateController {
    
    // MARK: - Properties
    
    public var state: PlayMediaUseCaseState

    private let mediaId: UUID
    private let audioPlayer: AudioPlayer
    private weak var delegate: PlayMediaUseCaseStateControllerDelegate?
    
    // MARK: - Initializers
    
    public init(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        delegate: PlayMediaUseCaseStateControllerDelegate
    ) {
        
        let _ = audioPlayer.pause()
        self.state = .paused(mediaId: mediaId, time: 0)

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
    
    public func pause() {}
    
    public func stop() {
        
        let _ = audioPlayer.stop()

        delegate?.didStop()
    }
    
    public func togglePlay() {
        play()
    }
}
