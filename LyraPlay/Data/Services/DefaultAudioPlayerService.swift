//
//  DefaultAudioService.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation
import AVFoundation
import MediaPlayer

// MARK: - Implementations

public final class DefaultAudioService: NSObject, AudioService, AVAudioPlayerDelegate {
    
    // MARK: - Properties
    
    private let audioSession: AVAudioSession
    private var player: AVAudioPlayer?
    private let commandCenter: MPRemoteCommandCenter
    
    public var volume: Observable<Double> = Observable(0.0)
    public var isPlaying = Observable(false)
    public var fileId: Observable<String?> = Observable(nil)
    public var currentTime: Observable<Double> = Observable(0.0)
    
    private var playerIsPlayingObserver: NSKeyValueObservation? = nil
    
    public let state: Observable<AudioServiceState> = .init(.initial)
    
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

        case .initial, .stopped, .finished, .interrupted, .paused:
            print("Wrong state")
            dump(self.state.value)
            break

        case .playing(let stateData):
            self.state.value = .finished(data: stateData)
            break
        }
    }
}

extension DefaultAudioService {
    
    public func play(fileId: String, data trackData: Data) async -> Result<Void, AudioServiceError> {
        
        try? audioSession.setActive(true)
        
        do {
            
            let player = try AVAudioPlayer(data: trackData)
            player.delegate = self
            
            self.player = player
            
            player.play()

            self.state.value = .playing(data: .init(fileId: fileId))
            
        } catch {

            state.value = .initial
            print("*** Unable to set up the audio player: \(error.localizedDescription) ***")
            return .failure(.internalError(error))
        }
        
        return .success(())
    }
    
    public func playAndWaitForEnd(fileId: String, data trackData: Data) async -> Result<Void, AudioServiceError> {
        
        return await withCheckedContinuation { continuation in
            
            let observerToken = ObserverToken()
            
            state.observe(on: observerToken) { [weak self] state in
                
                switch state {
                    
                case .initial:
                    return
                    
                case .playing(let stateData):
                    
                    if stateData.fileId == fileId {
                        return
                    }
                    
                case .finished:
                    continuation.resume(returning: .success(()))
                    
                default:
                    continuation.resume(returning: .failure(.waitIsInterrupted))
                }
                
                self?.state.remove(observer: observerToken)
            }
            
            Task {
                
                let result = await self.play(fileId: fileId, data: trackData)
                
                guard case .success = result else {

                    self.state.remove(observer: observerToken)
                    continuation.resume(returning: result)
                    return
                }
            }
        }
    }
    
    public func pause() async -> Result<Void, AudioServiceError> {
        
        guard let player = player else {
            return .failure(.noActiveFile)
        }
        
        player.pause()
        
        guard case .playing(data: let stateData) = state.value else {
            
            return .success(())
        }
        
        self.state.value = .paused(data: .init(fileId: stateData.fileId), time: player.currentTime)
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
                
            case .paused(let state, _),
                .interrupted(let state, _):
                self.state.value = .playing(data: state)
                
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
                
            case .playing(let state),
                .interrupted(let state, _),
                .paused(let state, _):
                self.state.value = .paused(data: state, time: player.currentTime)
                
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
