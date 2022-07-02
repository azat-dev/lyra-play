//
//  DefaultAudioPlayerService.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation
import AVFoundation
import MediaPlayer

public final class DefaultAudioPlayerService: AudioPlayerService {

    private let audioSession: AVAudioSession
    private var player: AVAudioPlayer?
    private let commandCenter: MPRemoteCommandCenter
    private let nowPlayingInfoService: NowPlayingInfoService
    
    public init(nowPlayingInfoService: NowPlayingInfoService) {

        self.nowPlayingInfoService = nowPlayingInfoService
        self.commandCenter = MPRemoteCommandCenter.shared()
        self.audioSession = AVAudioSession.sharedInstance()

        do {
            // Set the audio session category, mode, and options.
            try audioSession.setCategory(
                .playback,
                mode: .spokenAudio,
                options: [
                ]
            )
        } catch {
            print("Failed to set audio session category.")
        }
        
        setupRemoteControls()
    }
    
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
            
            self.nowPlayingInfoService.update(currentTime: player.currentTime, rate: player.rate)
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

    
    public func play(mediaInfo: MediaInfo, data trackData: Data) async -> Result<Void, Error> {
        
        try? audioSession.setActive(true)
        
        do {

            let player = try AVAudioPlayer(data: trackData)
            self.player = player
            
            player.play()
            
            nowPlayingInfoService.update(currentTime: player.currentTime, rate: player.rate)
            nowPlayingInfoService.update(from: mediaInfo)
            
        } catch {

            print("*** Unable to set up the audio player: \(error.localizedDescription) ***")
            return .failure(error)
        }
        
        return .success(())
    }
    
    public func pause() async -> Result<Void, Error> {
        
        player?.pause()
        return .success(())
    }
    
    public func stop() async -> Result<Void, Error> {
        
        player?.stop()
        return .success(())
    }
    
    public func seek(time: Int) async -> Result<Void, Error> {
        fatalError()
    }
    
    public func setVolume(value: Double) async -> Result<Void, Error> {

        player?.setVolume(Float(value), fadeDuration: 0)
        return .success(())
    }
}
