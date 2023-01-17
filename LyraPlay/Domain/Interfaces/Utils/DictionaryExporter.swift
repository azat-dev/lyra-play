//
//  DictionaryExporter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.01.23.
//

import Foundation

public protocol DictionaryExporter {
    
    func export(repository: DictionaryRepository) async -> Result<[ExportedDictionaryItem], Error>
}
