//
//  SubtitleInfo.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.07.22.
//

import Foundation

public struct SubtitlesInfo {
    
    public var mediaFileId: UUID
    public var language: String
    public var file: String
    
    public init(
        mediaFileId: UUID,
        language: String,
        file: String
    ) {
        
        self.mediaFileId = mediaFileId
        self.language = language
        self.file = file
    }
}
