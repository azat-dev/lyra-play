//
//  ImportDictionaryArchiveUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.01.2023.
//

public protocol ImportDictionaryArchiveUseCaseFactory {

    func create(
        dictionaryRepository: DictionaryRepository,
        dictionaryArchiveParser: DictionaryArchiveParser
    ) -> ImportDictionaryArchiveUseCase
}