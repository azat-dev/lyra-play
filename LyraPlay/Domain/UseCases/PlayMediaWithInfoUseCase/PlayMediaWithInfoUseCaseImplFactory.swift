//
//  PlayMediaWithInfoUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.22.
//

import Foundation

public final class PlayMediaWithInfoUseCaseImplFactory: PlayMediaWithInfoUseCaseFactory {
    
    // MARK: - Properties
    
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
        
        return PlayMediaWithInfoUseCaseImpl(
            playMediaWithTranslationsUseCaseFactory: playMediaWithTranslationsUseCaseFactory,
            showMediaInfoUseCaseFactory: showMediaInfoUseCaseFactory
        )
    }
}
