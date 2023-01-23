//
//  AudioSessionImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class AudioSessionImplSingleInstanceFactory: AudioSessionFactory {

    // MARK: - Properties

    private let semaphore = DispatchSemaphore(value: 1)
    
    private let mode: AudioSessionMode
    
    private weak var instance: AudioSession?
    
    // MARK: - Initializers

    public init(mode: AudioSessionMode) {
        
        self.mode = mode
    }

    // MARK: - Methods

    public func create() -> AudioSession {

        defer { semaphore.signal() }
        
        semaphore.wait()
        
        if let instance = instance {
            return instance
        }
        
        let newInstance = AudioSessionImpl(mode: mode)
        instance = newInstance
        
        return newInstance
    }
}
