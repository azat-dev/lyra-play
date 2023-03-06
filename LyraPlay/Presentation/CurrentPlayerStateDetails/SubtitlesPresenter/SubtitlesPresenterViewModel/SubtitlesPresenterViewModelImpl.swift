//
//  SubtitlesPresenterViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.10.22.
//

import Foundation
import Combine

public final class SubtitlesPresenterViewModelImpl: SubtitlesPresenterViewModel {
    
    // MARK: - Properties
    
    public let position = CurrentValueSubject<SubtitlesPosition?, Never>(nil)
    
    private var sentences: [SentenceViewModel]
    
    public var numberOfRows: Int
    
    // MARK: - Initializers
    
    public init(subtitles: Subtitles) {
        
        let toggleWord: ToggleWordCallback = { index, range in
            
            // FIXME: Add implementation    ppppp
        }
        
        sentences = subtitles.sentences.indices.map { sentenceIndex in
            
            let sentence = subtitles.sentences[sentenceIndex]
            
            return SentenceViewModelImpl(
                id: sentenceIndex,
                text: sentence.text,
                toggleWord: toggleWord
            )
        }
        
        self.numberOfRows = sentences.count
    }
    
    public func getSentenceViewModel(at index: Int) -> SentenceViewModel? {
        
        guard index < sentences.count else {
            return nil
        }
        
        return sentences[index]
    }
}

// MARK: - Input Methods

extension SubtitlesPresenterViewModelImpl {
    
    public func update(position: SubtitlesPosition?) {
        
        DispatchQueue.main.async { [weak self] in
            self?.updatePosition(position)
        }
    }
}

// MARK: - Handlers

extension SubtitlesPresenterViewModelImpl {
    
    private func updatePosition(_ newPosition: SubtitlesPosition?) {
        
        DispatchQueue.main.async {
            
            let prevPosition = self.position.value
            
            if prevPosition == newPosition {
                return
            }
            
            if let prevSentenceIndex = prevPosition?.sentenceIndex {
                
                var sentence = self.sentences[prevSentenceIndex]
                sentence.isActive = false
                self.sentences[prevSentenceIndex] = sentence
            }
            
            if let newSentenceIndex = newPosition?.sentenceIndex {
                var sentence = self.sentences[newSentenceIndex]
                sentence.isActive = true
                self.sentences[newSentenceIndex] = sentence
            }
            
            self.position.value = newPosition
        }
    }
}
