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
    
    private let audioSession: AVAudioSession
    private var player: AVAudioPlayer?
    private let commandCenter: MPRemoteCommandCenter
    
    private var playerIsPlayingObserver: NSKeyValueObservation? = nil
    
    public let state: CurrentValueSubject<AudioServiceState, Never> = .init(.initial)
    
    // MARK: - Initializers
    
    public override init() {
        
        self.audioSession = AVAudioSession.sharedInstance()
        self.player = nil
        self.commandCenter = MPRemoteCommandCenter.shared()
        
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
        
        setupRemoteControls()
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
    
    public func prepare(fileId: String, data trackData: Data) async -> Result<Void, AudioServiceError> {
        
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
    
    public func play() async -> Result<Void, AudioServiceError> {
        
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
    
    public func play(atTime: TimeInterval) async -> Result<Void, AudioServiceError> {

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
        
        let result: Result<Void, AudioServiceError> = await withCheckedContinuation { continuation  in
            
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
            
            Task {
                
                let result = await self.play()
                
                guard case .success = result else {
                    continuation.resume(returning: result)
                    return
                }
            }
        }
        
        
        return result
    }
    
    public func pause() async -> Result<Void, AudioServiceError> {
        
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
    
    public func stop() async -> Result<Void, AudioServiceError> {
        
        guard let player = player else {
            return .failure(.noActiveFile)
        }
        
        player.stop()
        
        self.player = nil
        
        self.state.value = .stopped
        return .success(())
    }
}

extension DefaultAudioService {
    
    func setupRemoteControls() {
        
        commandCenter.playCommand.addTarget { [unowned self] event in
            
            guard let player = self.player else {
                return .commandFailed
            }
            
            
            player.play()
            
            switch self.state.value {
                
            case .paused(let session, _),
                    .interrupted(let session, _):
                self.state.value = .playing(session: session)
                
            default:
                break
            }
            
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            
            guard let player = self.player else {
                return .commandFailed
            }
            
            if player.rate != 1.0 {
                return .commandFailed
            }
            
            player.pause()
            
            switch self.state.value {
                
            case .playing(let session),
                    .interrupted(let session, _),
                    .paused(let session, _):
                self.state.value = .paused(session: session, time: player.currentTime)
                
            default:
                break
            }
            
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { event in
            return .success
        }
        
        commandCenter.skipBackwardCommand.addTarget {[weak self] event in
            
            guard
                let self = self,
                let player = self.player
            else {
                return .commandFailed
            }
            
            let currentTime = player.currentTime
            
            if currentTime - 10 > 0 {
                player.play(atTime: player.currentTime - 10)
            }
            
            return .success
        }
        
        commandCenter.skipForwardCommand.addTarget { event in
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { event in
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { event in
            return .success
        }
    }
    
}
