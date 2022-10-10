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
