//
//  EditDictionaryItemUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation

public final class EditDictionaryItemUseCaseImplFactory: EditDictionaryItemUseCaseFactory {

    // MARK: - Properties

    private let dictionaryRepository: DictionaryRepository
    private let lemmatizer: Lemmatizer

    // MARK: - Initializers

    public init(
        dictionaryRepository: DictionaryRepository,
        lemmatizer: Lemmatizer
    ) {

        self.dictionaryRepository = dictionaryRepository
        self.lemmatizer = lemmatizer
    }

    // MARK: - Methods

    public func make() -> EditDictionaryItemUseCase {

        return EditDictionaryItemUseCaseImpl(
            dictionaryRepository: dictionaryRepository,
            lemmatizer: lemmatizer
        )
    }
}
