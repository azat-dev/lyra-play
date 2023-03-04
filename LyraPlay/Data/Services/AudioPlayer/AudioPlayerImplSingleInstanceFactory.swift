//
//  AudioPlayerImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class AudioPlayerImplSingleInstanceFactory: AudioPlayerFactory {
    
    // MARK: - Properties
    
    private var semaphore = DispatchSemaphore(value: 1)
    
    private weak var instance: AudioPlayer?
    
    private let audioSessionFactory: AudioSessionFactory
    
    // MARK: - Initializers
    
    public init(
        audioSessionFactory: AudioSessionFactory
    ) {
        
        self.audioSessionFactory = audioSessionFactory
    }
    
    // MARK: - Methods
    
    public func make() -> AudioPlayer {
        
        defer { semaphore.signal() }
        
        semaphore.wait()
        
        if let instance = instance {
            return instance
        }
        
        let audioSession = audioSessionFactory.make()
        let newInstance = AudioPlayerImpl(
            audioSession: audioSession
        )
        instance = newInstance
        
        return newInstance
    }
}
