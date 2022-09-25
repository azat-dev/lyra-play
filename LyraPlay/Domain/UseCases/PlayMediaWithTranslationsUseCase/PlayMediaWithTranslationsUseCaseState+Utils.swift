//
//  PlayMediaWithTranslationsUseCaseState+Utils.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.22.
//

import Foundation

extension PlayMediaWithTranslationsUseCaseState {
    
    public var session: PlayMediaWithTranslationsSession? {
        
        switch self {
            
        case .initial:
            return nil
            
        case .loading(let session), .loadFailed(let session), .loaded(let session, _), .playing(let session, _), .pronouncingTranslations(let session, _, _), .paused(let session, _, _), .stopped(let session), .finished(let session):
            
            return session
        }
    }
    
    public var subtitlesState: SubtitlesState? {
        
        switch self {
            
        case .initial, .loading, .loadFailed, .stopped, .finished:
            return nil
            
        case .playing(_, let subtitlesState), .pronouncingTranslations(_, let subtitlesState, _), .paused(_, let subtitlesState, _), .loaded(_, let subtitlesState):
            
            return subtitlesState
        }
    }
}
