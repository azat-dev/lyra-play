//
//  ProvideTranslationsToPlayUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class ProvideTranslationsToPlayUseCaseImplFactory: ProvideTranslationsToPlayUseCaseFactory {

    // MARK: - Properties

    private let provideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCase

    // MARK: - Initializers

    public init(provideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCase) {

        self.provideTranslationsForSubtitlesUseCase = provideTranslationsForSubtitlesUseCase
    }

    // MARK: - Methods

    public func create() -> ProvideTranslationsToPlayUseCase {

        return ProvideTranslationsToPlayUseCaseImpl(provideTranslationsForSubtitlesUseCase: provideTranslationsForSubtitlesUseCase)
    }
}
