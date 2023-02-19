//
//  DictionaryArchiveParserImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.01.2023.
//

import Foundation

public final class DictionaryArchiveParserImplFactory: DictionaryArchiveParserFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func make() -> DictionaryArchiveParser {

        return DictionaryArchiveParserImpl()
    }
}
