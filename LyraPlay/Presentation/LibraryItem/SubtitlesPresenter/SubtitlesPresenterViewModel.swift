//
//  SubtitlesPresenterViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.07.22.
//

import Foundation

// MARK: - Interfaces


public struct SentencePresentation: Equatable {

    public var items: [Item]
    
    public enum Item: Equatable {
        
        public struct Position: Equatable {
            
            public var itemIndex: Int
            public var startsAt: Int
            
            public init(itemIndex: Int, startsAt: Int) {
                self.itemIndex = itemIndex
                self.startsAt = startsAt
            }
        }
        
        case space(position: Position, text: String)
        case word(position: Position, text: String)
        case specialCharacter(position: Position, text: String)
    }
    
    public init(items: [SentencePresentation.Item]) {
        self.items = items
    }
}

public struct SubtitlesPosition {
    
    public var sentence: Int
    public var word: Int?
    
    public init(sentence: Int, word: Int? = nil) {
        
        self.sentence = sentence
        self.word = word
    }
}

public protocol SubtitlesPresenterViewModelOutput {

    var sentences: Observable<[SentencePresentation]?> { get }
    var currentPosition: Observable<SubtitlesPosition?> { get }
}

public protocol SubtitlesPresenterViewModelInput {

    func load() async
    
    func play(at: TimeInterval) async
    
    func pause() async
    
    func stop() async
}

public protocol SubtitlesPresenterViewModel: SubtitlesPresenterViewModelOutput, SubtitlesPresenterViewModelInput {
}

// MARK: - Implementations

public final class DefaultSubtitlesPresenterViewModel: SubtitlesPresenterViewModel {

    private let subtitles: Subtitles

    public let sentences: Observable<[SentencePresentation]?> = Observable(nil)
    public let currentPosition: Observable<SubtitlesPosition?> = Observable(nil)
    public let subtitlesIterator: SubtitlesIterator

    private var sentenceTimer: ActionTimer? = nil
    private var wordTimer: ActionTimer? = nil
    private var currentSpeed: Double = 1.0
    private var scheduler: Scheduler
    
    public init(
        subtitles: Subtitles,
        scheduler: Scheduler
    ) {
        
        self.subtitles = subtitles
        self.subtitlesIterator = DefaultSubtitlesIterator(subtitles: subtitles)
        self.scheduler = DefaultScheduler(
            timeMarksIterator: subtitlesIterator,
            actionTimerFactory: DefaultActionTimerFactory()
        )
    }
}

// MARK: - Input

extension DefaultSubtitlesPresenterViewModel {

    private static func splitNotSyncedSentence(text: String) -> [SentencePresentation.Item] {
        
        var items = [SentencePresentation.Item]()

        var currentWord = ""
        var currentWordStart: Int? = nil
        
        let appendCurrentWord = { () -> Void in
            
            guard currentWordStart != nil else {
                return
            }
            
            let word = SentencePresentation.Item.word(
                position: .init(
                    itemIndex: 0,
                    startsAt: currentWordStart!
                ),
                text: currentWord
            )
            
            items.append(word)
            currentWordStart = nil
            currentWord = ""
        }
        
        for (index, stringIndex) in text.indices.enumerated() {

            let character = text[stringIndex]
            
            if character.isNewline || character.isWhitespace {
                
                appendCurrentWord()
                
                let space = SentencePresentation.Item.space(
                    position: .init(
                        itemIndex: 0,
                        startsAt: index
                    ),
                    text: String(character)
                )
                
                items.append(space)
                continue
            }
            
            if character == "," {
                
                appendCurrentWord()
                
                let specialCharacter = SentencePresentation.Item.specialCharacter(
                    position: .init(
                        itemIndex: 0,
                        startsAt: index
                    ),
                    text: String(character)
                )
                
                items.append(specialCharacter)
                continue
            }
            
            
            if character == "-" && currentWordStart != nil {
                
                currentWord.append(character)
                continue
            }
            
            if !(character.isLetter || character.isNumber) {
                
                appendCurrentWord()
                
                let specialCharacter = SentencePresentation.Item.specialCharacter(
                    position: .init(
                        itemIndex: 0,
                        startsAt: index
                    ),
                    text: String(character)
                )
                items.append(specialCharacter)
                continue
            }
            
            if currentWordStart == nil {
                currentWordStart = index
                currentWord = ""
            }
            
            currentWord.append(character)
        }
        
        appendCurrentWord()
        
        return items
    }
    
    private static func parse(subtitles: Subtitles) async -> [SentencePresentation] {
        
        var result = [SentencePresentation]()
        
        for subtitlesSentence in subtitles.sentences {
            
            switch subtitlesSentence.text {
            case .notSynced(text: let text):
                let sentence = SentencePresentation(items: Self.splitNotSyncedSentence(text: text))
                result.append(sentence)
                break
                
            default:
                fatalError()
            }
        }
        
        return result
    }
    
    public func load() async {
        
        self.sentences.value = await Self.parse(subtitles: subtitles)
    }
    
    public func play(at time: TimeInterval) async {
        
        scheduler.start(at: time) { [weak self] time in
            
            guard let self = self else {
                return
            }
            
            self.currentPosition.value = self.subtitlesIterator.currentPosition
        }
    }
    
    public func pause() async {
        
        scheduler.pause()
    }
    
    public func stop() async {
        
        scheduler.stop()
    }
}
