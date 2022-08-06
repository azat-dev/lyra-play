//
//  TranslationItem.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.07.22.
//

import Foundation

public struct TranslationItem: Equatable {

    public var id: UUID?
    public var text: String
    public var mediaId: UUID?
    public var timeMark: UUID?
    public var position: TranslationItemPosition?
    
    public init(
        id: UUID?,
        text: String,
        mediaId: UUID? = nil,
        timeMark: UUID? = nil,
        position: TranslationItemPosition? = nil
    ) {
        
        self.id = id
        self.text = text
        self.mediaId = mediaId
        self.timeMark = timeMark
        self.position = position
    }
}
