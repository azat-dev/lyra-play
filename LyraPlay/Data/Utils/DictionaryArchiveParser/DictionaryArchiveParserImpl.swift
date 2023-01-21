//
//  DictionaryArchiveParserImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.01.2023.
//

import Foundation

public final class DictionaryArchiveParserImpl: DictionaryArchiveParser {

    // MARK: - Initializers

    public init() {}
}

// MARK: - Input Methods

extension DictionaryArchiveParserImpl {

    public func parse(data: Data) async -> Result<[ExportedDictionaryItem], Error> {

        fatalError()
    }
}

// MARK: - Output Methods

extension DictionaryArchiveParserImpl {

}