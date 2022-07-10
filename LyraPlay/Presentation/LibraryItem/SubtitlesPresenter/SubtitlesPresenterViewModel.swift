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
        case space(Int, String)
        case word(Int, String)
        case specialCharacter(Int, String)
    }
    
    public init(items: [SentencePresentation.Item]) {
        self.items = items
    }
}

public protocol SubtitlesPresenterViewModelOutput {

    var sentences: Observable<[SentencePresentation]?> { get }
    var currentSentenceIndex: Observable<Int?> { get }
    var currentWordIndex: Observable<Int?> { get }
}

public protocol SubtitlesPresenterViewModelInput {

    func load() async
}

public protocol SubtitlesPresenterViewModel: SubtitlesPresenterViewModelOutput, SubtitlesPresenterViewModelInput {
}

// MARK: - Implementations

public final class DefaultSubtitlesPresenterViewModel: SubtitlesPresenterViewModel {

    private var subtitles: Subtitles

    public let sentences: Observable<[SentencePresentation]?> = Observable(nil)
    public let currentSentenceIndex: Observable<Int?> = Observable(nil)
    public let currentWordIndex: Observable<Int?> = Observable(nil)

    public init(
        subtitles: Subtitles
    ) {
        
        self.subtitles = subtitles
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
            
            items.append(.word(currentWordStart!, currentWord))
            currentWordStart = nil
            currentWord = ""
        }
        
        for (index, stringIndex) in text.indices.enumerated() {

            let character = text[stringIndex]
            
            if character.isNewline || character.isWhitespace {
                
                appendCurrentWord()
                items.append(.space(index, String(character)))
                continue
            }
            
            if character == "," {
                
                appendCurrentWord()
                items.append(.specialCharacter(index, String(character)))
                continue
            }
            
            
            if character == "-" && currentWordStart != nil {
                
                currentWord.append(character)
                continue
            }
            
            if !(character.isLetter || character.isNumber) {
                
                appendCurrentWord()
                items.append(.specialCharacter(index, String(character)))
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
}
