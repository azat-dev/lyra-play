//
//  InitialAudioPlayerStateBlock.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.01.23.
//

import Foundation
import AVFoundation

public class InitialAudioPlayerStateController: NSObject, AudioPlayerStateController, AVAudioPlayerDelegate {
    
    // MARK: - Properties
    
    private unowned var context: AudioPlayerStateControllerContext
    
    public let currentState: AudioPlayerState
    
    // MARK: - Initializers
    
    public init(context: AudioPlayerStateControllerContext) {
        
        self.currentState = .initial
        self.context = context
    }
    
    // MARK: - Methods
    
    public func prepare(
        fileId: String,
        data trackData: Data
    ) -> Result<Void, AudioPlayerError> {
        
        do {
            
            let systemPlayer = try AVAudioPlayer(data: trackData)
            systemPlayer.delegate = self
            
            systemPlayer.prepareToPlay()
            
            let newController = LoadedAudioPlayerStateController(
                session: .init(
                    fileId: fileId,
                    systemPlayer: systemPlayer,
                    context: context
                )
            )
            
            context.setController(newController)
            
        } catch {
            
            print("*** Unable to set up the audio player: \(error.localizedDescription) ***")
            return .failure(.internalError(error))
        }
        
        return .success(())
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
