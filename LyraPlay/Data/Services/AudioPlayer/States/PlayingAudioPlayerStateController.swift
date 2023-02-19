//
//  PlayingAudioPlayerStateBlock.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.01.23.
//

import Foundation
import AVFAudio

public class PlayingAudioPlayerStateController: NSObject, AudioPlayerStateController, AVAudioPlayerDelegate {
    
    // MARK: - Properties
    
    private let session: ActiveAudioPlayerStateControllerSession

    public let currentState: AudioPlayerState
    
    // MARK: - Initializers
    
    
    public init(session: ActiveAudioPlayerStateControllerSession) {
       
        currentState = .playing(session: .init(fileId: session.fileId))
        self.session = session
    }
    
    // MARK: - Methods

    public func prepare(fileId: String, data: Data) -> Result<Void, AudioPlayerError> {

        let newController = InitialAudioPlayerStateController(context: session.context)
        session.context.setController(newController)
        
        return newController.prepare(fileId: fileId, data: data)
    }
    
    public func play() -> Result<Void, AudioPlayerError> {
        return .success(())
    }
    
    public func pause() -> Result<Void, AudioPlayerError> {
        
        session.systemPlayer.pause()
        session.context.deactivateAudioSession()
        
        session.systemPlayer.delegate = nil
        let newController = PausedAudioPlayerStateController(session: session)
        session.context.setController(newController)
        
        return .success(())
    }
    
    public func toggle() -> Result<Void, AudioPlayerError> {
        return pause()
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        let newController = FinishedAudioPlayerStateController(session: session)
        session.context.setController(newController)
    }
    
    public func stop() -> Result<Void, AudioPlayerError> {
        
        let newController = StoppedAudioPlayerStateController(context: session.context)
        session.context.setController(newController)
        
        return .success(())
    }
}
