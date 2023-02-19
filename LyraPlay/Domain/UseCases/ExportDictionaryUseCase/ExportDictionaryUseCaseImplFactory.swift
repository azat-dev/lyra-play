//
//  ExportDictionaryUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.01.2023.
//

import Foundation

public final class ExportDictionaryUseCaseImplFactory: ExportDictionaryUseCaseFactory {

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

    // MARK: - Methods

    public func make() -> ExportDictionaryUseCase {

        return ExportDictionaryUseCaseImpl(
            dictionaryRepository: dictionaryRepository,
            dictionaryExporter: dictionaryExporter
        )
    }
}
