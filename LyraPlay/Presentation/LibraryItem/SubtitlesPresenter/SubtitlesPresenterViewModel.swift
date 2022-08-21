//
//  SubtitlesPresenterViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.07.22.
//

import Foundation
import Combine

// MARK: - Interfaces

public enum SubtitlesPresentationState {
    
    case loading
    case playing(activeSentenceIndex: Int?, rows: [SentenceViewModel])
}

public protocol SubtitlesPresenterViewModelOutput {

    var state: CurrentValueSubject<SubtitlesPresentationState, Never> { get }
    
    func getSentenceViewModel(at index: Int) -> SentenceViewModel?
}

public protocol SubtitlesPresenterViewModelInput {

    func update(with: SubtitlesState?)
}

public protocol SubtitlesPresenterViewModel: SubtitlesPresenterViewModelOutput, SubtitlesPresenterViewModelInput {
}

// MARK: - Implementations

public final class DefaultSubtitlesPresenterViewModel: SubtitlesPresenterViewModel {

    // MARK: - Properties
    
    public let state = CurrentValueSubject<SubtitlesPresentationState, Never>(.loading)
    
    // MARK: - Initializers
    
    public init() {}

    public func getSentenceViewModel(at index: Int) -> SentenceViewModel? {

        guard
            case .playing(_, let rows) = state.value,
            index < rows.count
        else {
            return nil
        }

        return rows[index]
    }
}

// MARK: - Input Methods

extension DefaultSubtitlesPresenterViewModel {
    
    public func update(with subtitlesState: SubtitlesState?) {
        
        DispatchQueue.main.async { [weak self] in
            self?.updateState(subtitlesState)
        }
    }
}

// MARK: - Handlers

extension DefaultSubtitlesPresenterViewModel {
    
    private func updateState(_ subtitlesState: SubtitlesState?) {
    
        guard let subtitlesState = subtitlesState else {
            state.value = .loading
            return
        }
        
        var rows: [SentenceViewModel]

        if case .playing(let prevActiveSentenceIndex, let prevRows) = state.value {
             
            rows = prevRows
            
            if let prevActiveSentenceIndex = prevActiveSentenceIndex {
                rows[prevActiveSentenceIndex].isActive.value = false
            }
            
        } else {
            rows = getInitialModels(subtitlesState: subtitlesState)
        }
        
        
        if let newActiveSentenceIndex = subtitlesState.position?.sentenceIndex {
            rows[newActiveSentenceIndex].isActive.value = true
        }
        
        state.value = .playing(
            activeSentenceIndex: subtitlesState.position?.sentenceIndex,
            rows: rows
        )
    }
    
    private func getInitialModels(subtitlesState: SubtitlesState) -> [SentenceViewModel] {
        
        let sentences = subtitlesState.subtitles.sentences
        
        let toggleWord: ToggleWordCallback = { [weak self] index, range in
            self?.toggleWord(index, range)
        }
        
        return sentences.indices.map { sentenceIndex in
            
            let sentence = sentences[sentenceIndex]
            
            return DefaultSentenceViewModel(
                id: sentenceIndex,
                text: sentence.text,
                toggleWord: toggleWord
            )
        }
    }

    private func toggleWord(_ sentenceIndex: Int, _ tapRange: Range<String.Index>?) {
    }
}
