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
    
    public let position = CurrentValueSubject<SubtitlesTimeSlot?, Never>(nil)
    
    private var rows: [SubtitlesPresenterRowViewModel]
    
    public var numberOfRows: Int
    
    // MARK: - Initializers
    
    public init(subtitles: Subtitles, timeSlots: [SubtitlesTimeSlot]) {
        
        let toggleWord: ToggleWordCallback = { index, range in
            
            // FIXME: Add implementation
        }
        
        rows = timeSlots.map { timeSlot in

            guard let position = timeSlot.subtitlesPosition else {
                
                return SubtitlesPresenterRowViewModelImpl(
                    id: timeSlot.index,
                    isActive: false,
                    data: .empty,
                    delegateChanges: nil
                )
            }
            
            let sentence = subtitles.sentences[position.sentenceIndex]
            
            return SubtitlesPresenterRowViewModelImpl(
                id: timeSlot.index,
                isActive: false,
                data: .sentence(
                    SubtitlesPresenterRowViewModelSentenceDataImpl(
                        text: sentence.text,
                        toggleWord: toggleWord
                    )
                ),
                delegateChanges: nil
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
