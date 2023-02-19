//
//  ProvideTranslationsToPlayUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class ProvideTranslationsToPlayUseCaseImplFactory: ProvideTranslationsToPlayUseCaseFactory {
    
    // MARK: - Properties
    
    private let provideTranslationsForSubtitlesUseCaseFactory: ProvideTranslationsForSubtitlesUseCaseFactory
    
    // MARK: - Initializers
    
    public init(provideTranslationsForSubtitlesUseCaseFactory: ProvideTranslationsForSubtitlesUseCaseFactory) {
        
        self.provideTranslationsForSubtitlesUseCaseFactory = provideTranslationsForSubtitlesUseCaseFactory
    }
    
    // MARK: - Methods
    
    public func make() -> ProvideTranslationsToPlayUseCase {
        
        let provideTranslationsForSubtitlesUseCase = provideTranslationsForSubtitlesUseCaseFactory.make()
        
        return ProvideTranslationsToPlayUseCaseImpl(provideTranslationsForSubtitlesUseCase: provideTranslationsForSubtitlesUseCase)
    }
}
