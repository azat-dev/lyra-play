//
//  PlayMediaUseCaseStateControllerContext.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.02.23.
//

import Foundation

public protocol PlayMediaUseCaseStateControllerDelegate: AnyObject {
    
    func stop(mediaId: UUID, audioPlayer: AudioPlayer) -> Result<Void, PlayMediaUseCaseError>
    
    func didStop()
    
    func load(mediaId: UUID) async -> Result<Void, PlayMediaUseCaseError>
    
    func didFailLoad(mediaId: UUID)
    
    func didLoad(mediaId: UUID, audioPlayer: AudioPlayer)
    
    func didFinish(mediaId: UUID, audioPlayer: AudioPlayer)
    
    func pause(mediaId: UUID, audioPlayer: AudioPlayer) -> Result<Void, PlayMediaUseCaseError>
    
    func didPause(mediaId: UUID, audioPlayer: AudioPlayer)
    
    func play(mediaId: UUID, audioPlayer: AudioPlayer) -> Result<Void, PlayMediaUseCaseError>
    
    func play(atTime: TimeInterval, mediaId: UUID, audioPlayer: AudioPlayer) -> Result<Void, PlayMediaUseCaseError>
    
    func didStartPlay(mediaId: UUID, audioPlayer: AudioPlayer)
}
