//
//  SubtitlesPresenterViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.07.22.
//

import Foundation
import Combine

// MARK: - Interfaces

public struct SubtitlesPresentationState {
    
    public var activeSentenceIndex: Int?
    public var rows: [SentenceViewModel]
    
    public init(
        activeSentenceIndex: Int? = nil,
        rows: [SentenceViewModel]
    ) {
        
        self.activeSentenceIndex = activeSentenceIndex
        self.rows = rows
    }
}

public protocol SubtitlesPresenterViewModelOutput {
    
    var state: CurrentValueSubject<SubtitlesPresentationState, Never> { get }
    
    func getSentenceViewModel(at index: Int) -> SentenceViewModel?
}

public protocol SubtitlesPresenterViewModelInput {
    
    func update(position: SubtitlesPosition?)
}

public protocol SubtitlesPresenterViewModel: SubtitlesPresenterViewModelOutput, SubtitlesPresenterViewModelInput {
}
