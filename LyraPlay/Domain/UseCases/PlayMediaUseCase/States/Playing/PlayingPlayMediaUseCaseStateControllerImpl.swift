//
//  PlayingPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation
import Combine

public class PlayingPlayMediaUseCaseStateControllerImpl: PlayingPlayMediaUseCaseStateController {

    // MARK: - Properties
    
    private let mediaId: UUID
    private let audioPlayer: AudioPlayer
    private weak var delegate: PlayMediaUseCaseStateControllerDelegate?
    
    private var observers = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    public init(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        delegate: PlayMediaUseCaseStateControllerDelegate
    ) {
        
        self.mediaId = mediaId
        self.audioPlayer = audioPlayer
        self.delegate = delegate
        
        audioPlayer.state.sink { [weak self] state in
        
            guard let self = self else {
                return
            }
            
            guard case .finished = state else {
                return
            }
            
            delegate.didFinish(
                mediaId: self.mediaId,
                audioPlayer: self.audioPlayer
            )
            
        }.store(in: &observers)
    }
    
    // MARK: - Methods
    
    public func prepare(mediaId: UUID) {
        
        delegate?.didStartLoading(mediaId: mediaId)
    }
    
    public func play() {}
    
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
        pause()
    }
    
    public func execute() {
        
        let _ = audioPlayer.play()
    }
}
