//
//  Subtitles.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.07.22.
//

import Foundation


public struct Subtitles: Equatable {

    public var sentences: [Sentence]
    
    public init(sentences: [Sentence]) {
        self.sentences = sentences
    }

    public struct Sentence: Equatable {
        
        public var startTime: Double
        public var duration: Double
        public var text: SentenceText
        
        public init(
            startTime: Double,
            duration: Double,
            text: SentenceText
        ) {
            
            self.startTime = startTime
            self.duration = duration
            self.text = text
        }
    }

    public enum SentenceText: Equatable {
        
        case notSynced(text: String)
        case synced(items: [SyncedItem])
        
        func getText() -> String {
            
            switch self {
            case .notSynced(let text):
                return text
            case .synced(let items):
                return items.map { $0.text }.joined(separator: "")
            }
        }
    }
    
    public struct SyncedItem: Equatable {
        
        public var startTime: Double
        public var duration: Double
        public var text: String
        
        public init(
            startTime: Double,
            duration: Double,
            text: String
        ) {
            
            self.startTime = startTime
            self.duration = duration
            self.text = text
        }

    }
}
