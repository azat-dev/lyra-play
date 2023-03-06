//
//  SubtitlesPresenterViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.07.22.
//

import Foundation
import Combine

// MARK: - Interfaces

public protocol SubtitlesPresenterViewModelOutput {
    
    var numberOfRows: Int { get }
    
    var position: CurrentValueSubject<SubtitlesPosition?, Never> { get }
    
    func getSentenceViewModel(at index: Int) -> SentenceViewModel?
}

public protocol SubtitlesPresenterViewModelInput {
    
    func update(position: SubtitlesPosition?)
}

public protocol SubtitlesPresenterViewModel: SubtitlesPresenterViewModelOutput, SubtitlesPresenterViewModelInput {
}
