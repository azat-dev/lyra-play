//
//  ExportDictionaryUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.01.2023.
//

import Foundation

public final class ExportDictionaryUseCaseImpl: ExportDictionaryUseCase {

    // MARK: - Properties

    private let dictionaryRepository: DictionaryRepositoryOutputList
    private let dictionaryExporter: DictionaryExporter

    // MARK: - Initializers

    public init(
        dictionaryRepository: DictionaryRepositoryOutputList,
        dictionaryExporter: DictionaryExporter
    ) {

        self.dictionaryRepository = dictionaryRepository
        self.dictionaryExporter = dictionaryExporter
    }
}

// MARK: - Input Methods

extension ExportDictionaryUseCaseImpl {

}

// MARK: - Output Methods

extension ExportDictionaryUseCaseImpl {

    public func export() async -> Result<[ExportedDictionaryItem], ExportDictionaryUseCaseError> {

        fatalError()
    }
}