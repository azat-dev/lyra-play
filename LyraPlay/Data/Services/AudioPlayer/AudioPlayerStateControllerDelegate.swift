//
//  AudioPlayerStateControllerDelegate.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.02.23.
//

import Foundation
import AVFoundation

public struct AudioPlayerStateControllerSessionParams {
    
    let fileId: String
}

public struct AudioPlayerStateControllerActiveSession {
    
    let params: AudioPlayerStateControllerSessionParams
    let systemPlayer: AVAudioPlayer
}


public protocol AudioPlayerStateControllerDelegate: AnyObject {
    
    func load(fileId: String, data: Data) -> Result<Void, AudioPlayerError>
    
    func didLoad(session: ActiveAudioPlayerStateControllerSession)
    
    func stop(session: ActiveAudioPlayerStateControllerSession) -> Result<Void, AudioPlayerError>
    
    func didStop(withController: StoppedAudioPlayerStateController)
    
    func resumePlaying(session: ActiveAudioPlayerStateControllerSession) -> Result<Void, AudioPlayerError>
    
    func didResumePlaying(withController: PlayingAudioPlayerStateController)
    
    func pause(session: ActiveAudioPlayerStateControllerSession) -> Result<Void, AudioPlayerError>
    
    func didPause(withController: PausedAudioPlayerStateController)
    
    func startPlaying(
        atTime: TimeInterval,
        session: ActiveAudioPlayerStateControllerSession
    ) -> Result<Void, AudioPlayerError>
    
    func didStartPlaying(withController: PlayingAudioPlayerStateController)
    
    func didFinishPlaying(session: ActiveAudioPlayerStateControllerSession)
    
    func seekPaused(
        atTime: TimeInterval,
        session: ActiveAudioPlayerStateControllerSession
    )
}

