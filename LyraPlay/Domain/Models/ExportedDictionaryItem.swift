//
//  ExportedDictionaryItem.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 16.01.23.
//

import Foundation

public struct ExportedDictionaryItem: Codable {
    
    var original: String
    var translations: [String]
}
