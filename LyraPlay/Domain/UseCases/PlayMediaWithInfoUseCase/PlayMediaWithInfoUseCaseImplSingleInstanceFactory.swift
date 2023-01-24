//
//  PlayMediaWithInfoUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.22.
//

import Foundation

public final class PlayMediaWithInfoUseCaseImplSingleInstanceFactory: PlayMediaWithInfoUseCaseFactory {
    
    // MARK: - Properties
    
    private let semaphore = DispatchSemaphore(value: 1)
    
    private weak var instance: PlayMediaWithInfoUseCase?
    
    private let playMediaWithTranslationsUseCaseFactory: PlayMediaWithTranslationsUseCaseFactory
    private let showMediaInfoUseCaseFactory: ShowMediaInfoUseCaseFactory
    
    // MARK: - Initializers
    
    public init(
        playMediaWithTranslationsUseCaseFactory: PlayMediaWithTranslationsUseCaseFactory,
        showMediaInfoUseCaseFactory: ShowMediaInfoUseCaseFactory
    ) {
        
        self.playMediaWithTranslationsUseCaseFactory = playMediaWithTranslationsUseCaseFactory
        self.showMediaInfoUseCaseFactory = showMediaInfoUseCaseFactory
    }
    
    // MARK: - Methods
    
    public func create() -> PlayMediaWithInfoUseCase {
        
        defer { semaphore.signal() }
        
        semaphore.wait()
        
        if let instance = instance {
            return instance
        }
        
        let newInstance = PlayMediaWithInfoUseCaseImpl(
            playMediaWithTranslationsUseCaseFactory: playMediaWithTranslationsUseCaseFactory,
            showMediaInfoUseCaseFactory: showMediaInfoUseCaseFactory
        )
        
        instance = newInstance
        
        return newInstance
    }
}
