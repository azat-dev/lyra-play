//
//  ImportDictionaryArchiveUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.01.2023.
//

import Foundation

public final class ImportDictionaryArchiveUseCaseImplFactory: ImportDictionaryArchiveUseCaseFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func create(
        dictionaryRepository: DictionaryRepository,
        dictionaryArchiveParser: DictionaryArchiveParser
    ) -> ImportDictionaryArchiveUseCase {

        return ImportDictionaryArchiveUseCaseImpl(
            dictionaryRepository: dictionaryRepository,
            dictionaryArchiveParser: dictionaryArchiveParser
        )
    }
}