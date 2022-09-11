//
//  LoadDictionaryItemUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 11.09.2022.
//

import Foundation

public final class LoadDictionaryItemUseCaseImpl: LoadDictionaryItemUseCase {

    // MARK: - Properties

    private let dictionaryRepository: DictionaryRepository

    // MARK: - Initializers

    public init(dictionaryRepository: DictionaryRepository) {

        self.dictionaryRepository = dictionaryRepository
    }
}

// MARK: - Input Methods

extension LoadDictionaryItemUseCaseImpl {

    public func load(itemId: UUID) async -> Result<DictionaryItem, LoadDictionaryItemUseCaseError> {

        fatalError()
    }
}

// MARK: - Output Methods

extension LoadDictionaryItemUseCaseImpl {

}