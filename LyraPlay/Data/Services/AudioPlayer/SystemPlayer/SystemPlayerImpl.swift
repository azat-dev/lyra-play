//
//  SystemPlayerImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.04.23.
//

import Foundation
import AVFAudio

public final class SystemPlayerImpl: NSObject, SystemPlayer, AVAudioPlayerDelegate {
    
    // MARK: - Properties
    
    private let _audioPlayer: AVAudioPlayer
    
    private lazy var audioPlayer: AVAudioPlayer = {
        
        _audioPlayer.delegate = self
        
        return _audioPlayer
    } ()
    
    public var currentTime: TimeInterval {
        get {
            return audioPlayer.currentTime
        }
        
        set {
            audioPlayer.currentTime = newValue
        }
    }
    
    public var duration: TimeInterval {
        return audioPlayer.duration
    }
    
    public weak var delegate: SystemPlayerDelegate?
    
    // MARK: - Initializers
    
    public init(data: Data) throws {
        
        _audioPlayer = try AVAudioPlayer(data: data)
    }
    
    
    // MARK: - Methods
    
    public func stop() {
        audioPlayer.stop()
    }
    
    public func pause() {
        audioPlayer.pause()
    }
    
    public func prepareToPlay() -> Bool {
        return audioPlayer.prepareToPlay()
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        delegate?.audioPlayerDidFinishPlaying(player: self, successfully: flag)
    }
    
    public func play() -> Bool {
        return audioPlayer.play()
    }
    
    public func play(atTime: TimeInterval) -> Bool {
        return audioPlayer.play(atTime: atTime)
    }
}
