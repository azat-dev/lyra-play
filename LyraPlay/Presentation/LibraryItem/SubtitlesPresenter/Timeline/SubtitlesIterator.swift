//
//  SubtitlesIterator.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 11.07.22.
//

import Foundation

// MARK: - Interfaces


public struct SubtitlesItem {
    
    public var sentence: Subtitles.Sentence
    public var word: Subtitles.SyncedItem?
    
    public init(sentence: Subtitles.Sentence, word: Subtitles.SyncedItem? = nil) {
        
        self.sentence = sentence
        self.word = word
    }
}

public protocol SubtitlesIterator: TimeMarksIterator {
    
    var currentPosition: SubtitlesPosition? { get }

    var currentItem: SubtitlesItem? { get }
}

// MARK: - Implementations

public final class DefaultSubtitlesIterator: SubtitlesIterator {
    
    public var currentPosition: SubtitlesPosition?

    public var currentTime: TimeInterval? { getTime(item: currentItem) }
    
    public var currentItem: SubtitlesItem? { getItem(position: currentPosition) }
    
    private let subtitles: Subtitles
    
    private var sentences: [Subtitles.Sentence] { subtitles.sentences }
    
    private lazy var sentencesStartTimes: [TimeInterval] = {
        sentences.map { $0.startTime }
    } ()
    
    public init(subtitles: Subtitles) {
        
        self.subtitles = subtitles
    }
    
    private func getItem(position: SubtitlesPosition?) -> SubtitlesItem? {
        
        guard let position = position else {
            return nil
        }

        let sentence = sentences[position.sentence]
        
        guard
            let wordIndex = position.word,
            let words = getWords(sentence: sentence)
        else {
            return .init(sentence: sentence)
        }
        
        guard wordIndex < words.count else {
            return nil
        }
        
        return .init(
            sentence: sentence,
            word: words[wordIndex]
        )
    }
    
    private func getTime(item: SubtitlesItem?) -> TimeInterval? {
        
        return item?.word?.startTime ?? item?.sentence.startTime
    }
    
    private func getTime(position: SubtitlesPosition?) -> TimeInterval? {
        
        return getTime(item: getItem(position: position))
    }
}

extension DefaultSubtitlesIterator {
    
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
    
    public func move(at time: TimeInterval) -> TimeInterval? {
        
        guard
            let recentSentence = searchRecentSentence(at: time)
        else {
            currentPosition = nil
            return currentTime
        }
        
        let recentWord = searchRecentWord(at: time, in: recentSentence)
        currentPosition = .init(
            sentence: recentSentence,
            word: recentWord
        )
        
        return currentTime
    }
    

    private func getWords(sentence: Subtitles.Sentence) -> [Subtitles.SyncedItem]? {
    
        switch sentence.text {
        case .notSynced:
            return nil
            
        case .synced(items: let items):
            return items
        }
    }
    
    public func getNextPosition() -> SubtitlesPosition? {
        
        guard let currentPosition = currentPosition else {
        
            if let firstSentence = sentences.first {
                
                guard
                    let words = getWords(sentence: firstSentence),
                    let firstWord = words.first,
                    firstWord.startTime == firstSentence.startTime
                else {
                    return .init(sentence: 0, word: nil)
                }

                return .init(sentence: 0, word: 0)
            }
            
            return nil
        }
        
        let sentence = sentences[currentPosition.sentence]
        
        if
            let words = getWords(sentence: sentence),
            !words.isEmpty
        {
            
            guard let currentWordIndex = currentPosition.word else {

                return .init(
                    sentence: currentPosition.sentence,
                    word: 0
                )
            }
            
            let nextWordIndex = currentWordIndex + 1
            if nextWordIndex < words.count {
                return .init(
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
            return .init(
                sentence: nextSentenceIndex,
                word: nil
            )
        }
        
        return .init(
            sentence: nextSentenceIndex,
            word: firstWordOfNextSentence.startTime == nextSentence.startTime ? 0 : nil
        )
    }
    
    public func getNext() -> TimeInterval? {
        
        let nextPosition = getNextPosition()
        return getTime(position: nextPosition)
    }
    
    public func next() -> TimeInterval? {
        
        let nextPosition = getNextPosition()
        currentPosition = nextPosition
        
        return currentTime
    }
}
