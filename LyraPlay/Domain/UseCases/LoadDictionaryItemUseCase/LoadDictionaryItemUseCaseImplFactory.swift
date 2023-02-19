//
//  LoadDictionaryItemUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 11.09.2022.
//

import Foundation

public final class LoadDictionaryItemUseCaseImplFactory: LoadDictionaryItemUseCaseFactory {

    // MARK: - Properties

    private let dictionaryRepository: DictionaryRepository

    // MARK: - Initializers

    public init(dictionaryRepository: DictionaryRepository) {

        self.dictionaryRepository = dictionaryRepository
    }

    // MARK: - Methods

    public func make() -> LoadDictionaryItemUseCase {

        return LoadDictionaryItemUseCaseImpl(dictionaryRepository: dictionaryRepository)
    }
}
