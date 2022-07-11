//
//  SubtitlesIterator.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 11.07.22.
//

import Foundation

// MARK: - Interfaces

public protocol SubtitlesIterator {
    
    func searchRecentSentence(at: TimeInterval) -> (index: Int, sentence: Subtitles.Sentence)?
    
    func searchRecentWord(at: TimeInterval, in: Int) -> (index: Int, word: Subtitles.SyncedItem)?
    
    func getNextSentence(from: Int) -> (index: Int, sentence: Subtitles.Sentence)?
    
    func getFirstWord(in: Int) -> Subtitles.SyncedItem?
}

// MARK: - Implementations

public final class DefaultSubtitlesIterator: SubtitlesIterator {
    
    private let subtitles: Subtitles
    private lazy var sentencesStartTimes: [TimeInterval] = { subtitles.sentences.map { $0.startTime }
    } ()
    
    public init(subtitles: Subtitles) {
        
        self.subtitles = subtitles
    }
    
    private static func searchRecentItem(items: [TimeInterval], time: TimeInterval) -> Int? {
        
        let lastIndex = items.lastIndex { $0 <= time }
        return lastIndex
    }
    
    
    public func searchRecentSentence(at time: TimeInterval) -> (index: Int, sentence: Subtitles.Sentence)? {
        
        let sentences = subtitles.sentences
        
        let index = Self.searchRecentItem(
            items: sentencesStartTimes,
            time: time
        )
        
        guard let index = index else {
            return nil
        }

        return (index, sentences[index])
    }
    
    public func searchRecentWord(at time: TimeInterval, in sentenceIndex: Int) -> (index: Int, word: Subtitles.SyncedItem)? {
        
        let sentences = subtitles.sentences
        
        if sentenceIndex >= sentences.count {
            return nil
        }
        
        let sentence = sentences[sentenceIndex]
        
        switch sentence.text {
        case .notSynced:
            return nil
            
        case .synced(items: let items):
        
            let index = Self.searchRecentItem(
                items: items.map { $0.startTime },
                time: time
            )
            
            guard let index = index else {
                return nil
            }

            return (index, items[index])
        }
    }
    
    public func getNextSentence(from currentSentenceIndex: Int) -> (index: Int, sentence: Subtitles.Sentence)? {
        
        let sentences = subtitles.sentences
        let nextIndex = currentSentenceIndex + 1
        
        if nextIndex >= sentences.count {
            return nil
        }
        
        return (nextIndex, sentences[nextIndex])
    }
    
    public func getFirstWord(in sentenceIndex: Int) -> Subtitles.SyncedItem? {
        
        let sentences = subtitles.sentences
        
        if sentenceIndex >= sentences.count {
            return nil
        }
        
        let sentence = sentences[sentenceIndex]
        
        switch sentence.text {
        case .notSynced:
            return nil
            
        case .synced(items: let items):
            return items.first
        }
    }
}

