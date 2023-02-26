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
}
