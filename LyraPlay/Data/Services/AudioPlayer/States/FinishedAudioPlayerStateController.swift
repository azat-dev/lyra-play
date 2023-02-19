//
//  FinishedAudioPlayerStateBlock.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.01.23.
//

import Foundation
import AVFAudio

public class FinishedAudioPlayerStateController: AudioPlayerStateController {
    
    // MARK: - Properties
    
    private let session: ActiveAudioPlayerStateControllerSession
    
    public let currentState: AudioPlayerState
    
    // MARK: - Initializers
    
    public init(session: ActiveAudioPlayerStateControllerSession) {
        
        currentState = .finished(session: .init(fileId: session.fileId))
        self.session = session
    }
    
    // MARK: - Methods
    
    public func prepare(fileId: String, data: Data) -> Result<Void, AudioPlayerError> {
        
        session.systemPlayer.stop()
        let newController = InitialAudioPlayerStateController(context: session.context)
        session.context.setController(newController)
        
        return newController.prepare(fileId: fileId, data: data)
    }
    
    public func play() -> Result<Void, AudioPlayerError> {

        let newController = InitialAudioPlayerStateController(context: session.context)
        return newController.play()
    }
    
    public func pause() -> Result<Void, AudioPlayerError> {
        
        return .success(())
    }
    
    public func toggle() -> Result<Void, AudioPlayerError> {
        return play()
    }
    
    public func stop() -> Result<Void, AudioPlayerError> {

        let newController = StoppedAudioPlayerStateController(context: session.context)
        session.context.setController(newController)
        
        return .success(())
    }
}
