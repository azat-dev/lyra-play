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
    private let textSplitterFactory: TextSplitterFactory
    private let lemmatizerFactory: LemmatizerFactory

    // MARK: - Initializers

    public init(
        dictionaryRepository: DictionaryRepository,
        textSplitterFactory: TextSplitterFactory,
        lemmatizerFactory: LemmatizerFactory
    ) {

        self.dictionaryRepository = dictionaryRepository
        self.textSplitterFactory = textSplitterFactory
        self.lemmatizerFactory = lemmatizerFactory
    }

    // MARK: - Methods

    public func make() -> ProvideTranslationsForSubtitlesUseCase {

        let textSplitter = textSplitterFactory.make()
        let lemmatizer = lemmatizerFactory.make()
        
        return ProvideTranslationsForSubtitlesUseCaseImpl(
            dictionaryRepository: dictionaryRepository,
            textSplitter: textSplitter,
            lemmatizer: lemmatizer
        )
    }
}
