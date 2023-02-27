//
//  LoadingAudioPlayerStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.02.23.
//

import Foundation
import AVFoundation

public class LoadingAudioPlayerStateController: AudioPlayerStateController {
    
    // MARK: - Properties
    
    private let fileId: String
    private let data: Data
    
    private weak var delegate: AudioPlayerStateControllerDelegate?
    
    // MARK: - Initializers
    
    public init(
        fileId: String,
        data: Data,
        delegate: AudioPlayerStateControllerDelegate
    ) {
        
        self.fileId = fileId
        self.data = data
        self.delegate = delegate
    }
    
    public func prepare(fileId: String, data trackData: Data) -> Result<Void, AudioPlayerError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.load(fileId: fileId, data: trackData)
    }
    
    public func resume() -> Result<Void, AudioPlayerError> {
        
        return .failure(.noActiveFile)
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, AudioPlayerError> {
        
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
    
    public func runLoading() -> Result<Void, AudioPlayerError> {
        
        do {
            
            let systemPlayer = try AVAudioPlayer(data: data)
            systemPlayer.prepareToPlay()
            
            delegate?.didLoad(
                session: .init(
                    fileId: fileId,
                    systemPlayer: systemPlayer
                )
            )
            
        } catch {
            
            print("*** Unable to set up the audio player: \(error.localizedDescription) ***")
            return .failure(.internalError(error))
        }
        
        return .success(())
    }
}
