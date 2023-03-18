//
//  SubtitlesPresenterViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.10.22.
//

import Foundation
import Combine

public final class SubtitlesPresenterViewModelImplFactory: SubtitlesPresenterViewModelFactory {
    
    public func make(
        subtitles: Subtitles,
        timeSlots: [SubtitlesTimeSlot],
        delegate: SubtitlesPresenterViewModelDelegate
    ) -> SubtitlesPresenterViewModel {
        
        return SubtitlesPresenterViewModelImpl(
            subtitles: subtitles,
            timeSlots: timeSlots,
            delegate: delegate
        )
    }
}
