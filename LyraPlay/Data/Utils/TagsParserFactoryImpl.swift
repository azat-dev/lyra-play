//
//  TagsParserFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.08.22.
//

import Foundation

public final class TagsParserFactoryImpl: TagsParserFactory {
    
    public init() {}
    
    public func create() -> TagsParser {
        
        return TagsParserImpl()
    }
}
