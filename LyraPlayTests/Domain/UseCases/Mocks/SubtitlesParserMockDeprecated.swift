//
//  SubtitlesParserMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 09.07.22.
//

import Foundation
import LyraPlay

final class SubtitlesParserMockDeprecated: SubtitlesParser {

    typealias ParseCallback = (_ text: String, _ fileName: String) async -> Result<Subtitles, SubtitlesParserError>
    
    public var resolve: ParseCallback?
    
    func parse(_ text: String, fileName: String) async -> Result<Subtitles, SubtitlesParserError> {
        
        guard let resolve = resolve else {
            fatalError("Specify resolver")
        }
        
        return await resolve(text, fileName)
    }
}
