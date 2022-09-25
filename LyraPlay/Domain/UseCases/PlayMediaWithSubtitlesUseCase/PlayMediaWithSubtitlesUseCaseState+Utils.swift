//
//  PlayMediaWithSubtitlesUseCaseState+Utils.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.22.
//

import Foundation

extension PlayMediaWithSubtitlesUseCaseState {
    
    var session: PlayMediaWithSubtitlesSessionParams? {
        
        switch self {
            
        case .initial:
            return nil
            
        case .loading(let session), .loadFailed(let session),
                .loaded(let session, _), .playing(let session, _),
                .paused(let session, _, _), .finished(let session), .stopped(let session):
            
            return session
        }
    }
    
    var subtitlesState: SubtitlesState? {
        
        switch self {
            
        case .initial, .loading, .loadFailed, .stopped, .finished:
            return nil
            
        case .loaded(_, let subtitlesState), .playing(_, let subtitlesState), .paused(_, let subtitlesState, _):
            
            return subtitlesState
        }
    }
}
