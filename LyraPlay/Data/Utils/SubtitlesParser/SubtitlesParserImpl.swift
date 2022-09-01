//
//  SubtitlesParserImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class SubtitlesParserImpl: SubtitlesParser {
    
    public typealias FileExtension = String

    // MARK: - Properties

    private let parsers: [FileExtension: SubtitlesParser]

    // MARK: - Initializers

    public init(parsers: [FileExtension: SubtitlesParser]) {

        self.parsers = parsers
    }
}

// MARK: - Methods

extension SubtitlesParserImpl {

    public func parse(_ text: String, fileName: String) async -> Result<Subtitles, SubtitlesParserError> {
        
        let fileExtension = URL(fileURLWithPath: fileName).pathExtension.lowercased()
        
        guard let parser = parsers[".\(fileExtension)"] else {
            return .failure(.internalError(nil))
        }
        
        return await parser.parse(text, fileName: fileName)
    }
}
