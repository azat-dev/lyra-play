//
//  ImportDictionaryArchiveUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.01.2023.
//

import Foundation

public final class ImportDictionaryArchiveUseCaseImplFactory: ImportDictionaryArchiveUseCaseFactory {

    // MARK: - Properties
    
    let dictionaryRepository: DictionaryRepository
    let dictionaryArchiveParserFactory: DictionaryArchiveParserFactory
    
    // MARK: - Initializers

    public init(
        dictionaryRepository: DictionaryRepository,
        dictionaryArchiveParserFactory: DictionaryArchiveParserFactory
        
    ) {
        
        self.dictionaryRepository = dictionaryRepository
        self.dictionaryArchiveParserFactory = dictionaryArchiveParserFactory
    }

    // MARK: - Methods

    public func make() -> ImportDictionaryArchiveUseCase {

        let dictionaryArchiveParser = dictionaryArchiveParserFactory.make()
        
        return ImportDictionaryArchiveUseCaseImpl(
            dictionaryRepository: dictionaryRepository,
            dictionaryArchiveParser: dictionaryArchiveParser
        )
    }
}
