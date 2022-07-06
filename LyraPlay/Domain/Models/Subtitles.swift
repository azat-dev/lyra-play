//
//  Subtitles.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.07.22.
//

import Foundation


public struct Subtitles {
    
    public var sentences: [Sentence]
}

extension Subtitles {
    
    public struct Sentence {
        
        public var startTime: Double
        public var duration: Double
        public var text: SentenceText
    }

    public enum SentenceText {
        
        case notSynced(text: String)
        case synced(items: SyncedItem)
    }
    
    public struct SyncedItem {
        
        public var startTime: Double
        public var duration: Double
        public var text: String
    }
}
