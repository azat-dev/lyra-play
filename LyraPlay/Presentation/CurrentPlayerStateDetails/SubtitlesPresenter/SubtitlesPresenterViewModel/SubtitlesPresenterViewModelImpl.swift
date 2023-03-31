//
//  SubtitlesPresenterViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.10.22.
//

import Foundation
import Combine
import UIKit

public final class SubtitlesPresenterViewModelImpl: SubtitlesPresenterViewModel {
    
    // MARK: - Properties
    
    public let position = CurrentValueSubject<SubtitlesTimeSlot?, Never>(nil)
    
    private var rows: [SubtitlesPresenterRowViewModel]
    
    public var numberOfRows: Int
    
    private var currentDictionaryWords: [Int: [NSRange]]?
    
    // MARK: - Initializers
    
    public init(
        subtitles: Subtitles,
        timeSlots: [SubtitlesTimeSlot],
        dictionaryWords: [Int: [NSRange]],
        delegate: SubtitlesPresenterViewModelDelegate
    ) {
        
        let toggleWord: ToggleWordCallback = { [weak delegate] index, range in
            
            guard
                let delegate,
                let range = range,
                let senteceIndex = timeSlots[index].subtitlesPosition?.sentenceIndex
            else {
                return
            }
            
            let sentence = subtitles.sentences[senteceIndex]
            let foundTextComponent = sentence.components.first { $0.range.overlaps(range) }
            
            guard
                let foundTextComponent = foundTextComponent,
                case .word = foundTextComponent.type
            else {
                return
            }
            
            let substring = sentence.text[foundTextComponent.range]
            let word = String(substring)
            
            delegate.subtitlesPresenterViewModelDidTapWord(text: word)
        }
        
        rows = timeSlots.map { timeSlot in

            guard let position = timeSlot.subtitlesPosition else {
                
                return SubtitlesPresenterRowViewModelImpl(
                    id: timeSlot.index,
                    isActive: false,
                    data: .empty
                )
            }
            
            let sentenceIndex = position.sentenceIndex
            let sentence = subtitles.sentences[sentenceIndex]
            
            return SubtitlesPresenterRowViewModelImpl(
                id: timeSlot.index,
                isActive: false,
                data: .sentence(
                    SubtitlesPresenterRowViewModelSentenceDataImpl(
                        text: sentence.text,
                        toggleWord: toggleWord,
                        dictionaryWords: dictionaryWords[sentenceIndex]
                    )
                )
            )
        }
        
        self.numberOfRows = rows.count
    }
    
    public func getRowViewModel(at index: Int) -> SubtitlesPresenterRowViewModel? {
        
        guard index < rows.count else {
            return nil
        }
        
        return rows[index]
    }
}

// MARK: - Input Methods

extension SubtitlesPresenterViewModelImpl {
    
    public func update(position: SubtitlesTimeSlot?) {
        
        DispatchQueue.main.async { [weak self] in
            self?.updatePosition(position)
        }
    }
    
    private func update(newDictionaryWords: [Int: [NSRange]]) {
        
        for (index, ranges) in newDictionaryWords {
            
            let rowViewModel = getRowViewModel(at: index)
            
            guard
                let rowViewModel = rowViewModel,
                case .sentence(let sentence) = rowViewModel.data
            else {
                continue
            }
            
            sentence.dictionaryWords.value = ranges
        }
    }
    
    private func hidePreviousDictionaryWords(prevDictionaryWords: [Int: [NSRange]]) {
        
        for (index, _) in prevDictionaryWords {
            
            guard currentDictionaryWords?[index] == nil else {
                continue
            }
            
            let rowViewModel = getRowViewModel(at: index)
            
            guard
                let rowViewModel = rowViewModel,
                case .sentence(let sentence) = rowViewModel.data
            else {
                continue
            }
            
            sentence.dictionaryWords.value = nil
        }
    }
    
    public func update(dictionaryWords: [Int: [NSRange]]) {
        
        if dictionaryWords == currentDictionaryWords {
            return
        }
        
        let prevDictionaryWords = self.currentDictionaryWords
        self.currentDictionaryWords = dictionaryWords
        
        if let prevDictionaryWords = prevDictionaryWords {
            hidePreviousDictionaryWords(prevDictionaryWords: prevDictionaryWords)
        }
        
        update(newDictionaryWords: dictionaryWords)
    }
}

// MARK: - Handlers

extension SubtitlesPresenterViewModelImpl {
    
    private func updatePosition(_ newPosition: SubtitlesTimeSlot?) {
        
        DispatchQueue.main.async {

            let prevPosition = self.position.value

            if prevPosition == newPosition {
                return
            }

            if
                let prevIndex = prevPosition?.index,
                prevIndex < self.rows.count
            {
                self.rows[prevIndex].deactivate()
            }

            if
                let newIndex = newPosition?.index,
                newIndex < self.rows.count
            {
                self.rows[newIndex].activate()
            }
            
            self.position.value = newPosition
        }
    }
}
