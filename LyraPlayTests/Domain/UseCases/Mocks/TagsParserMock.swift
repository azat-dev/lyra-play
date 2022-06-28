//
//  TagsParserMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 28.06.22.
//

import Foundation
import LyraPlay

typealias TagsParserCallback = (_ data: Data) -> AudioFileTags?

final class TagsParserMock: TagsParser {
    
    private var callback: TagsParserCallback
    
    init(callback: @escaping TagsParserCallback) {
        self.callback = callback
    }
    
    func parse(data: Data) async -> Result<AudioFileTags?, Error> {
        
        let tags = callback(data)
        return .success(tags)
    }
}
