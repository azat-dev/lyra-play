//
//  LoadedAudioPlayerStateBlock.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.01.23.
//

import Foundation
import AVFAudio

public class LoadedAudioPlayerStateController: NSObject, AudioPlayerStateController {
    
    // MARK: - Properties
    
    public let session: ActiveAudioPlayerStateControllerSession
    
    public let currentState: AudioPlayerState
    
    // MARK: - Initializers
    
    public init(session: ActiveAudioPlayerStateControllerSession) {
        
        currentState = .loaded(session: .init(fileId: session.fileId))
        self.session = session
    }
    
    // MARK: - Methods

    public func play() -> Result<Void, AudioPlayerError> {
        
        session.context.activateAudioSession()

        let newController = PlayingAudioPlayerStateController(session: session)
        session.systemPlayer.delegate = newController

        session.context.setController(newController)
        session.systemPlayer.play()
        
        return .success(())
    }
    
    public func toggle() -> Result<Void, AudioPlayerError> {
        return play()
    }
    
    public func prepare(fileId: String, data: Data) -> Result<Void, AudioPlayerError> {
        
        let newController = InitialAudioPlayerStateController(context: session.context)
        session.context.setController(newController)
        
        return newController.prepare(fileId: fileId, data: data)
    }
    
    public func pause() -> Result<Void, AudioPlayerError> {
        return .failure(.noActiveFile)
    }
    
    public func stop() -> Result<Void, AudioPlayerError> {
        
        let newController = StoppedAudioPlayerStateController(context: session.context)
        session.context.setController(newController)
        
        return .success(())
    }
}
