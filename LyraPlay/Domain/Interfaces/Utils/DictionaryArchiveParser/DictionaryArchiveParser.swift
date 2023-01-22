//
//  DictionaryArchiveParser.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.01.2023.
//

import Foundation

public protocol DictionaryArchiveParserInput: AnyObject {

    func parse(data: Data) async -> Result<[ExportedDictionaryItem], Error>
}

public protocol DictionaryArchiveParserOutput: AnyObject {

}

public protocol DictionaryArchiveParser: DictionaryArchiveParserOutput, DictionaryArchiveParserInput {

}