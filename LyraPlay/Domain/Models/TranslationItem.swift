//
//  TranslationItem.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.07.22.
//

import Foundation

public struct TranslationItem: Equatable {

    public var text: String
    public var mediaId: UUID?
    public var timeMark: UUID?
    public var position: String?
    
    public init(
        text: String,
        mediaId: UUID? = nil,
        timeMark: UUID? = nil,
        position: String? = nil
    ) {
        self.text = text
        self.mediaId = mediaId
        self.timeMark = timeMark
        self.position = position
    }
}
