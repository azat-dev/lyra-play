//
//  PlayMediaUseCaseStateControllerContext.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.02.23.
//

import Foundation

public protocol PlayMediaUseCaseStateControllerDelegate: AnyObject {
    
    func didStop()
    
    func didStartLoading(mediaId: UUID)
    
    func didFailedLoad(mediaId: UUID)
    
    func didLoaded(mediaId: UUID, audioPlayer: AudioPlayer)
    
    func didFinish(mediaId: UUID, audioPlayer: AudioPlayer)
    
    func didPause(mediaId: UUID, audioPlayer: AudioPlayer)
    
    func didStartPlaying(mediaId: UUID, audioPlayer: AudioPlayer)
    
    func set(newState: PlayMediaUseCaseStateController)
}
