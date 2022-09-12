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

    // MARK: - Initializers

    public init(dictionaryRepository: DictionaryRepository) {

        self.dictionaryRepository = dictionaryRepository
    }

    // MARK: - Methods

    public func create() -> EditDictionaryItemUseCase {

        return EditDictionaryItemUseCaseImpl(dictionaryRepository: dictionaryRepository)
    }
}