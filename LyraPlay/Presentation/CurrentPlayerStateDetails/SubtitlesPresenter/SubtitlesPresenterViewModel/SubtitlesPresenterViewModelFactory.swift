//
//  SubtitlesPresenterViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.10.22.
//

import Foundation
import Combine

public protocol SubtitlesPresenterViewModelFactory {
    
    func make(
        subtitles: Subtitles,
        timeSlots: [SubtitlesTimeSlot],
        dictionaryWords: [Int : [NSRange]],
        delegate: SubtitlesPresenterViewModelDelegate
    ) -> SubtitlesPresenterViewModel
}
