//
//  EditDictionaryListUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.09.2022.
//

import Foundation

public final class EditDictionaryListUseCaseImplFactory: EditDictionaryListUseCaseFactory {

    // MARK: - Properties

    private let dictionaryRepository: DictionaryRepository

    // MARK: - Initializers

    public init(dictionaryRepository: DictionaryRepository) {

        self.dictionaryRepository = dictionaryRepository
    }

    // MARK: - Methods

    public func create() -> EditDictionaryListUseCase {

        return EditDictionaryListUseCaseImpl(dictionaryRepository: dictionaryRepository)
    }
}