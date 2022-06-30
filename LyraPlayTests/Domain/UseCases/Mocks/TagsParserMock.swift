//
//  TagsParserMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 28.06.22.
//

import Foundation
import LyraPlay

typealias TagsParserCallback = (_ url: URL) -> AudioFileTags?

final class TagsParserMock: TagsParser {
    
    private var callback: TagsParserCallback
    
    init(callback: @escaping TagsParserCallback) {
        self.callback = callback
    }
    
    func parse(url: URL) async -> Result<AudioFileTags?, Error> {
        
        let tags = callback(url)
        return .success(tags)
    }
}
