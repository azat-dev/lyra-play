//
//  DefaultAudioPlayer.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation
import AVFoundation
import MediaPlayer
import Combine

// MARK: - Implementations

public final class DefaultAudioPlayer: NSObject, AudioPlayer, AVAudioPlayerDelegate {
    
    // MARK: - Properties

    private let audioSession: AudioSession
    private var player: AVAudioPlayer?
    
    private var playerIsPlayingObserver: NSKeyValueObservation? = nil
    
    public let state: CurrentValueSubject<AudioPlayerState, Never> = .init(.initial)
    
    // MARK: - Initializers
    
    public init(audioSession: AudioSession) {
        
        self.audioSession = audioSession
        self.player = nil
    }
}

// MARK: - Input methods

extension DefaultAudioPlayer {
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully: Bool) {
        
        guard successfully else {
            return
        }
        
        switch self.state.value {
            
        case .initial, .stopped, .finished, .paused, .loaded:
            print("Wrong state")
            dump(self.state.value)
            break
            
        case .playing(let stateData):
            self.state.value = .finished(session: stateData)
            break
        }
    }
}

extension DefaultAudioPlayer {
    
    public func prepare(fileId: String, data trackData: Data) -> Result<Void, AudioPlayerError> {
        
        audioSession.activate()
        
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
    
    public func play() -> Result<Void, AudioPlayerError> {
        
        guard
            let player = self.player,
            let session = self.state.value.session
        else {
            
            return .failure(.noActiveFile)
        }
        
        audioSession.activate()
        
        player.play()
        self.state.value = .playing(session: session)
        
        return .success(())
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, AudioPlayerError> {
        
        guard
            let player = self.player,
            let session = state.value.session
        else {
            
            return .failure(.noActiveFile)
        }
        
        audioSession.activate()
        
        player.play(atTime: atTime)
        self.state.value = .playing(session: session)
        
        return .success(())
    }
    
    public func playAndWaitForEnd() async -> Result<Void, AudioPlayerError> {
        
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
    
    public func pause() -> Result<Void, AudioPlayerError> {
        
        guard
            let player = player
        else {
            return .failure(.noActiveFile)
        }
        
        audioSession.deactivate()
        player.pause()
        
        guard case .playing(let session) = state.value else {
            return .success(())
        }
        
        self.state.value = .paused(session: session, time: player.currentTime)
        return .success(())
    }
    
    public func stop() -> Result<Void, AudioPlayerError> {
        
        guard let player = player else {
            return .failure(.noActiveFile)
        }
        
        audioSession.deactivate()
        player.stop()
        self.player = nil
        
        self.state.value = .stopped
        return .success(())
    }
}
