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
    
    public let state: CurrentValueSubject<SubtitlesPresentationState, Never>
    
    // MARK: - Initializers
    
    public init(subtitles: Subtitles) {
        
        state = .init(
            .init(
                activeSentenceIndex: nil,
                rows: Self.getInitialModels(subtitles: subtitles, position: nil)
            )
        )
    }

    public func getSentenceViewModel(at index: Int) -> SentenceViewModel? {

        let rows = state.value.rows
        
        guard index < rows.count else {
            return nil
        }

        return rows[index]
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
    
    private func updatePosition(_ position: SubtitlesPosition?) {
    
        let prevState = state.value
        var rows = prevState.rows
        
        if let prevActiveSentenceIndex = prevState.activeSentenceIndex {
            rows[prevActiveSentenceIndex].isActive.value = false
        }
        
        if let newActiveSentenceIndex = position?.sentenceIndex {
            rows[newActiveSentenceIndex].isActive.value = true
        }
        
        state.value = .init(
            activeSentenceIndex: position?.sentenceIndex,
            rows: rows
        )
    }
    
    private static func getInitialModels(subtitles: Subtitles, position: SubtitlesPosition?) -> [SentenceViewModel] {
        
        let sentences = subtitles.sentences
        
        let toggleWord: ToggleWordCallback = { index, range in

            // FIXME: Add implementation
            fatalError("Add implementations")
        }
        
        return sentences.indices.map { sentenceIndex in
            
            let sentence = sentences[sentenceIndex]
            
            return SentenceViewModelImpl(
                id: sentenceIndex,
                text: sentence.text,
                toggleWord: toggleWord
            )
        }
    }
}
