//
//  DefaultAudioService.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation
import AVFoundation
import MediaPlayer

public final class DefaultAudioService: AudioService {
    
    private let audioSession: AVAudioSession
    private var player: AVAudioPlayer?
    private let commandCenter: MPRemoteCommandCenter
    
    public var volume: Observable<Double> = Observable(0.0)
    public var isPlaying = Observable(false)
    public var fileId: Observable<String?> = Observable(nil)
    public var currentTime: Observable<Double> = Observable(0.0)
    
    private var playerIsPlayingObserver: NSKeyValueObservation? = nil
    
    public init() {

        self.audioSession = AVAudioSession.sharedInstance()
        self.player = nil
        self.commandCenter = MPRemoteCommandCenter.shared()

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

extension DefaultAudioService {
    
//    private func bind(to player: AVAudioPlayer) {
//
//        playerIsPlayingObserver = player.observe(\.isPlaying, options: [.initial, .new, .old, .prior]) { [weak self] player, change in
//
//
//            debugPrint(player.isPlaying)
//            debugPrint(change)
//
//            guard let newIsPlaying = change.newValue else {
//                return
//            }
//
//            guard self?.isPlaying.value != newIsPlaying else {
//                return
//            }
//
//            self?.isPlaying.value = newIsPlaying
//            if !newIsPlaying {
//                self?.fileId.value = nil
//            }
//        }
//    }
//
//    private func removeBinding(to player: AVAudioPlayer) {
//
//        playerIsPlayingObserver?.invalidate()
//    }
}

extension DefaultAudioService {
    
    public func play(fileId: String, data trackData: Data) async -> Result<Void, AudioServiceError> {
        
        try? audioSession.setActive(true)

        do {

//            if let prevPlayer = self.player {
//                removeBinding(to: prevPlayer)
//            }
            
            let player = try AVAudioPlayer(data: trackData)
//            bind(to: player)
            
            
            self.player = player
            
            player.play()
            
            self.fileId.value = fileId
            self.isPlaying.value = true
            
        } catch {

            print("*** Unable to set up the audio player: \(error.localizedDescription) ***")
            return .failure(.internalError(error))
        }
        
        return .success(())
    }
    
    public func pause() async -> Result<Void, AudioServiceError> {
        
        guard let player = player else {
            return .failure(.noActiveFile)
        }
        
        self.isPlaying.value = false
        player.pause()
        return .success(())
    }
    
    public func stop() async -> Result<Void, AudioServiceError> {
        
        guard let player = player else {
            return .failure(.noActiveFile)
        }
        
        player.stop()
//        removeBinding(to: player)
        self.player = nil
        self.isPlaying.value = false
        self.fileId.value = nil
        self.currentTime.value = 0
        
        return .success(())
    }
    
    public func seek(time: Double) async -> Result<Void, AudioServiceError> {
        fatalError()
    }
    
    public func setVolume(value: Double) async -> Result<Void, AudioServiceError> {

        player?.setVolume(Float(value), fadeDuration: 0)
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
            return .success
        }

        commandCenter.pauseCommand.addTarget { [unowned self] event in
            
            guard let player = self.player else {
                return .commandFailed
            }
            
            if player.rate == 1.0 {
                player.pause()
                return .success
            }
            
            return .commandFailed
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
