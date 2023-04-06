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
    
    private let systemPlayerFactory: SystemPlayerFactory
    
    // MARK: - Initializers
    
    public init(systemPlayerFactory: SystemPlayerFactory) {
        self.systemPlayerFactory = systemPlayerFactory
    }
    
    // MARK: - Methods
    
    public func make() -> AudioPlayer {
        
        defer { semaphore.signal() }
        
        semaphore.wait()
        
        if let instance = instance {
            return instance
        }
        
        let newInstance = AudioPlayerImpl(systemPlayerFactory: systemPlayerFactory)
        instance = newInstance
        
        return newInstance
    }
}
