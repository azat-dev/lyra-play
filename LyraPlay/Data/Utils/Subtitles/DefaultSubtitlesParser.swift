//
//  DefaultSubtitlesParser.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.08.22.
//

import Foundation

public final class DefaultSubtitlesParser: SubtitlesParser {
    
    public typealias FileExtension = String
    
    // MARK: - Properties
    
    private let parsers: [FileExtension: SubtitlesParser]
    
    // MARK: - Initializers
    
    public init(parsers: [FileExtension: SubtitlesParser]) {
        
        self.parsers = parsers
    }
    
    // MARK: - Methods
    
    public func parse(_ text: String, fileName: String) async -> Result<Subtitles, SubtitlesParserError> {
        
        let fileExtension = URL(fileURLWithPath: fileName).pathExtension.lowercased()
        
        guard let parser = parsers[".\(fileExtension)"] else {
            return .failure(.internalError(nil))
        }
        
        return await parser.parse(text, fileName: fileName)
    }
}
