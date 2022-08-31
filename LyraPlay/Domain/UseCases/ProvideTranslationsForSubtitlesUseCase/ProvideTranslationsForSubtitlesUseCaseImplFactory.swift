//
//  ProvideTranslationsForSubtitlesUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class ProvideTranslationsForSubtitlesUseCaseImplFactory: ProvideTranslationsForSubtitlesUseCaseFactory {

    // MARK: - Properties

    private let dictionaryRepository: DictionaryRepository
    private let textSplitter: TextSplitter
    private let lemmatizer: Lemmatizer

    // MARK: - Initializers

    public init(
        dictionaryRepository: DictionaryRepository,
        textSplitter: TextSplitter,
        lemmatizer: Lemmatizer
    ) {

        self.dictionaryRepository = dictionaryRepository
        self.textSplitter = textSplitter
        self.lemmatizer = lemmatizer
    }

    // MARK: - Methods

    public func create() -> ProvideTranslationsForSubtitlesUseCase {

        return ProvideTranslationsForSubtitlesUseCaseImpl(
            dictionaryRepository: dictionaryRepository,
            textSplitter: textSplitter,
            lemmatizer: lemmatizer
        )
    }
}
