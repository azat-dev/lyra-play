//
//  PlaySubtitlesUseCaseState+Utils.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.22.
//

import Foundation

extension PlaySubtitlesUseCaseState {
    
    public var position: SubtitlesPosition? {
        
        switch self {
            
        case .initial, .stopped, .finished:
            return nil
            
        case .playing(let position), .paused(let position):
            return position
        }
    }
}
