//
//  TagsParserFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.08.22.
//

import Foundation

public protocol TagsParserFactory {
    
    func create() -> TagsParser
}

