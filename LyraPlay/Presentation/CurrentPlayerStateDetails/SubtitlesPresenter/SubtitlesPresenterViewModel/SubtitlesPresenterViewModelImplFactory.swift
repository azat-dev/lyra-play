//
//  SubtitlesPresenterViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.10.22.
//

import Foundation
import Combine

public final class SubtitlesPresenterViewModelImplFactory: SubtitlesPresenterViewModelFactory {
    
    public func create(subtitles: Subtitles) -> SubtitlesPresenterViewModel {
        
        return SubtitlesPresenterViewModelImpl(subtitles: subtitles)
    }
}
