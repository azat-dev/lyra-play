//
//  SubtitlesPresenterViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.07.22.
//

import Foundation
import Combine

public protocol SubtitlesPresenterViewModelDelegate: AnyObject {
    
    func subtitlesPresenterViewModelDidTapWord(text: String)
}


// MARK: - Interfaces

public protocol SubtitlesPresenterViewModelOutput {
    
    var numberOfRows: Int { get }
    
    var position: CurrentValueSubject<SubtitlesTimeSlot?, Never> { get }
    
    func getRowViewModel(at index: Int) -> SubtitlesPresenterRowViewModel?
}

public protocol SubtitlesPresenterViewModelInput {
    
    func update(position: SubtitlesTimeSlot?)
}

public protocol SubtitlesPresenterViewModel: SubtitlesPresenterViewModelOutput, SubtitlesPresenterViewModelInput {
}
