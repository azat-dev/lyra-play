//
//  DictionaryArchiveParserFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.01.2023.
//

public protocol DictionaryArchiveParserFactory {

    func create() -> DictionaryArchiveParser
}