//
//  DefaultAudioService.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation
import AVFoundation
import MediaPlayer
import Combine

// MARK: - Implementations

public final class DefaultAudioService: NSObject, AudioService, AVAudioPlayerDelegate {
    
    // MARK: - Properties
    
    private var audioSession: AVAudioSession {
        AVAudioSession.sharedInstance()
    }
    
    private var player: AVAudioPlayer?
    
    private var playerIsPlayingObserver: NSKeyValueObservation? = nil
    
    public let state: CurrentValueSubject<AudioServiceState, Never> = .init(.initial)
    
    // MARK: - Initializers
    
    public override init() {
        
        self.player = nil
        super.init()
        
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

// MARK: - Input methods

extension DefaultAudioService {
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully: Bool) {
        
        guard successfully else {
            return
        }
        
        switch self.state.value {
            
        case .initial, .stopped, .finished, .interrupted, .paused, .loaded:
            print("Wrong state")
            dump(self.state.value)
            break
            
        case .playing(let stateData):
            self.state.value = .finished(session: stateData)
            break
        }
    }
}

extension DefaultAudioService {
    
    public func prepare(fileId: String, data trackData: Data) -> Result<Void, AudioServiceError> {
        
        try? audioSession.setActive(true)
        
        do {
            
            let player = try AVAudioPlayer(data: trackData)
            player.delegate = self
            
            self.player = player
            
            player.prepareToPlay()
            self.state.value = .loaded(session: .init(fileId: fileId))
            
        } catch {
            
            state.value = .initial
            print("*** Unable to set up the audio player: \(error.localizedDescription) ***")
            return .failure(.internalError(error))
        }
        
        return .success(())
    }
    
    public func play() -> Result<Void, AudioServiceError> {
        
        guard
            let player = self.player,
            let session = self.state.value.session
        else {
            
            return .failure(.noActiveFile)
        }
        
        try? audioSession.setActive(true)
        
        player.play()
        self.state.value = .playing(session: session)
        
        return .success(())
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, AudioServiceError> {
        
        guard
            let player = self.player,
            let session = state.value.session
        else {
            
            return .failure(.noActiveFile)
        }
        
        try? audioSession.setActive(true)
        
        player.play(atTime: atTime)
        self.state.value = .playing(session: session)
        
        return .success(())
    }
    
    public func playAndWaitForEnd() async -> Result<Void, AudioServiceError> {
        
        guard let currentSession = state.value.session else {
            
            return .failure(.noActiveFile)
        }
        
        var stateCancellation: AnyCancellable?
        defer { stateCancellation?.cancel() }
        
        var isFinished = false
        var isSetupCall = true
        
        return await withCheckedContinuation { continuation  in
            
            stateCancellation = state.sink { state in
                
                if isSetupCall {
                    isSetupCall = false
                    return
                }
                
                guard !isFinished else {
                    return
                }
                
                switch state {
                    
                case .initial:
                    return
                    
                case .playing(let session):
                    
                    if session == currentSession {
                        return
                    }
                    
                    continuation.resume(returning: .failure(.waitIsInterrupted))
                    return
                    
                case .finished(let session):
                    if session == currentSession {
                        
                        isFinished = true
                        continuation.resume(returning: .success(()))
                        return
                    }
                    
                    continuation.resume(returning: .failure(.waitIsInterrupted))
                    return
                    
                default:
                    continuation.resume(returning: .failure(.waitIsInterrupted))
                }
            }
            
            let result = self.play()
            
            guard case .success = result else {
                continuation.resume(returning: result)
                return
            }
        }
    }
    
    public func pause() -> Result<Void, AudioServiceError> {
        
        guard
            let player = player
        else {
            return .failure(.noActiveFile)
        }
        
        player.pause()
        
        guard case .playing(let session) = state.value else {
            return .success(())
        }
        
        self.state.value = .paused(session: session, time: player.currentTime)
        return .success(())
    }
    
    public func stop() -> Result<Void, AudioServiceError> {
        
        guard let player = player else {
            return .failure(.noActiveFile)
        }
        
        player.stop()
        self.player = nil
        
        self.state.value = .stopped
        return .success(())
    }
}
