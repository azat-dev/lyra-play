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
            
        case .activeSession(let session, _):
            return session
            
        case .noActiveSession:
            return nil
        }
    }    
}
