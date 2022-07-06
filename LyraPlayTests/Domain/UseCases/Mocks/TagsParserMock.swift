//
//  TagsParserMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 28.06.22.
//

import Foundation
import LyraPlay


final class TagsParserMock: TagsParser {
    
    typealias Callback = (_ url: URL) -> AudioFileTags
    
    public var callback: Callback? = nil
    
    func parse(url: URL) async -> Result<AudioFileTags, Error> {
        
        let tags = callback!(url)
        return .success(tags)
    }
}
