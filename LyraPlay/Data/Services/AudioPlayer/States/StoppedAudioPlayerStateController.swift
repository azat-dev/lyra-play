//
//  StoppedAudioPlayerStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.02.23.
//

import Foundation
import AVFoundation

public class StoppedAudioPlayerStateController: NSObject, AudioPlayerStateController, AVAudioPlayerDelegate {
    
    // MARK: - Properties
    
    private unowned var context: AudioPlayerStateControllerContext
    
    public let currentState: AudioPlayerState
    
    // MARK: - Initializers
    
    public init(context: AudioPlayerStateControllerContext) {
        
        self.currentState = .stopped
        self.context = context
    }
    
    // MARK: - Methods
    
    public func prepare(
        fileId: String,
        data: Data
    ) -> Result<Void, AudioPlayerError> {
        
        let newController = InitialAudioPlayerStateController(context: context)
        context.setController(newController)
        
        return newController.prepare(fileId: fileId, data: data)
    }
    
    public func play() -> Result<Void, AudioPlayerError> {
        return .failure(.noActiveFile)
    }
    
    public func pause() -> Result<Void, AudioPlayerError> {
        return .failure(.noActiveFile)
    }
    
    public func toggle() -> Result<Void, AudioPlayerError> {
        return .failure(.noActiveFile)
    }
    
    public func stop() -> Result<Void, AudioPlayerError> {
        return .failure(.noActiveFile)
    }
}
