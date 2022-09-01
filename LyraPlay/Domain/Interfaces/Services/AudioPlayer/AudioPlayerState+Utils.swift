//
//  AudioPlayerState+Utils.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.22.
//

import Foundation

extension AudioPlayerState {
    
    public var session: AudioPlayerSession? {
        
        switch self {
            
        case .initial, .stopped:
            return nil

        case .playing(let session), .loaded(let session), .paused(let session, _), .finished(let session):
            return session
        }
    }
}
