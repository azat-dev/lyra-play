//
//  AudioSessionImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation
import AVFoundation

public final class AudioSessionImpl: AudioSession {
    
    // MARK: - Properties
    
    private var audioSession: AVAudioSession {
        AVAudioSession.sharedInstance()
    }
    
    // MARK: - Initializers
    
    public init() {
        
        do {
            // Set the audio session category, mode, and options.
            try audioSession.setCategory(
                .playback,
                mode: .spokenAudio,
                policy: .longFormAudio,
                options: [
                ]
            )
        } catch {
            print("Failed to set audio session category.")
        }
    }
}

// MARK: - Input Methods

extension AudioSessionImpl {
    
    public func activate() -> Result<Void, AudioSessionError> {
        
        do {
            
            try audioSession.setActive(true)
        } catch {
            return .failure(.internalError(error))
        }
        
        return .success(())
    }
    
    public func deactivate() -> Result<Void, AudioSessionError> {
        
        do {
            
            try audioSession.setActive(false)
        } catch {
            return .failure(.internalError(error))
        }
        
        return .success(())
    }}