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
    
    public init() {

        self.audioSession = AVAudioSession.sharedInstance()

        do {
            // Set the audio session category, mode, and options.
            try audioSession.setCategory(
                .playback,
                mode: .spokenAudio,
                options: []
            )
        } catch {
            print("Failed to set audio session category.")
        }
    }
    
    public func play(trackId: String, track: Data) async -> Result<Void, Error> {
        
        try? audioSession.setActive(true)
        
        do {

            player = try AVAudioPlayer(data: track)
            player?.play()
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
        fatalError()
    }
}
