//
//  SubtitlesParserImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class SubtitlesParserImplFactory: SubtitlesParserFactory {
    
    // MARK: - Properties
    
    private let parsers: [SubtitlesParserImpl.FileExtension: SubtitlesParser]
    
    // MARK: - Initializers
    
    public init(parsers: [SubtitlesParserImpl.FileExtension: SubtitlesParser]) {
        
        self.parsers = parsers
    }
    
    // MARK: - Methods
    
    public func create() -> SubtitlesParser {
        
        return SubtitlesParserImpl(parsers: parsers)
    }
}
