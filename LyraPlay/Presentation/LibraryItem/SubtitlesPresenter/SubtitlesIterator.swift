//
//  SubtitlesIterator.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 11.07.22.
//

import Foundation

// MARK: - Interfaces

public typealias SubtitlesIteratorPosition = (sentence: Int, word: Int?)

public protocol SubtitlesIterator {
    
    func move(to: TimeInterval) -> SubtitlesIteratorPosition?
    
    func getNext() -> SubtitlesIteratorPosition?
    
    func next() -> SubtitlesIteratorPosition?
    
    var position: SubtitlesIteratorPosition? { get }
}

// MARK: - Implementations

public final class DefaultSubtitlesIterator: SubtitlesIterator {
    
    private let subtitles: Subtitles
    
    private var sentences: [Subtitles.Sentence] { subtitles.sentences }
    
    private lazy var sentencesStartTimes: [TimeInterval] = {
        sentences.map { $0.startTime }
    } ()
    
    private var currentPosition: SubtitlesIteratorPosition? = nil
    
    public var position: SubtitlesIteratorPosition? { currentPosition }
    
    public init(subtitles: Subtitles) {
        
        self.subtitles = subtitles
    }
    
    private static func searchRecentItem(items: [TimeInterval], time: TimeInterval) -> Int? {
        
        let lastIndex = items.lastIndex { $0 <= time }
        return lastIndex
    }
    
    
    private func searchRecentSentence(at time: TimeInterval) -> Int? {
        
        return Self.searchRecentItem(
            items: sentencesStartTimes,
            time: time
        )
    }
    
    private func searchRecentWord(at time: TimeInterval, in sentenceIndex: Int) -> Int? {
        
        if sentenceIndex >= sentences.count {
            return nil
        }
        
        let sentence = sentences[sentenceIndex]
        
        switch sentence.text {
        case .notSynced:
            return nil

        case .synced(items: let words):
            return Self.searchRecentItem(
                items: words.map { $0.startTime },
                time: time
            )
        }
    }
    
    public func move(to time: TimeInterval) -> SubtitlesIteratorPosition? {
        
        guard
            let recentSentence = searchRecentSentence(at: time)
        else {
            return nil
        }
        
        let recentWord = searchRecentWord(at: time, in: recentSentence)
        currentPosition = (recentSentence, recentWord)
        
        return currentPosition
    }
    

    private func getWords(sentence: Subtitles.Sentence) -> [Subtitles.SyncedItem]? {
    
        switch sentence.text {
        case .notSynced:
            return nil
            
        case .synced(items: let items):
            return items
        }
    }
    
    public func getNext() -> SubtitlesIteratorPosition? {
        
        guard let currentPosition = currentPosition else {
        
            if let firstSentence = sentences.first {
                
                guard
                    let words = getWords(sentence: firstSentence),
                    let firstWord = words.first,
                    firstWord.startTime == firstSentence.startTime
                else {
                    return (sentence: 0, word: nil)
                }

                return (sentence: 0, word: 0)
            }
            
            return nil
        }
        
        let sentence = sentences[currentPosition.sentence]
        
        if
            let words = getWords(sentence: sentence),
            !words.isEmpty
        {
            
            guard let currentWordIndex = currentPosition.word else {

                return (
                    sentence: currentPosition.sentence,
                    word: 0
                )
            }
            
            let nextWordIndex = currentWordIndex + 1
            if nextWordIndex < words.count {
                return (
                    sentence: currentPosition.sentence,
                    word: nextWordIndex
                )
            }
        }
        
        let nextSentenceIndex = currentPosition.sentence + 1
        
        guard nextSentenceIndex < sentences.count else {
            return nil
        }

        let nextSentence = sentences[nextSentenceIndex]
        let nextSentenceWords = getWords(sentence: nextSentence)
        
        guard
            let firstWordOfNextSentence = nextSentenceWords?.first
        else {
            return (
                sentence: nextSentenceIndex,
                word: nil
            )
        }

        return (
            sentence: nextSentenceIndex,
            word: firstWordOfNextSentence.startTime == nextSentence.startTime ? 0 : nil
        )
    }
    
    public func next() -> SubtitlesIteratorPosition? {
        
        let nextPosition = getNext()
        currentPosition = nextPosition
        
        return nextPosition
    }
}
