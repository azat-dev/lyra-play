//
//  PlayMediaWithSubtitlesUseCaseState+Utils.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.22.
//

import Foundation

extension PlayMediaWithSubtitlesUseCaseState {
    
    var session: PlayMediaWithSubtitlesSessionParams? {

        guard case .activeSession(let session, _) = self else {
            return nil
        }

        return session
    }
    
    var subtitlesState: SubtitlesState? {
        
        guard case .activeSession(_, .loaded(_, let subtitlesState)) = self else {
            return nil
        }

        return subtitlesState
    }
}
