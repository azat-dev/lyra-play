//
//  PlayMediaUseCaseState+MediaId.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.22.
//

import Foundation

extension PlayMediaUseCaseState {
    
    public var mediaId: UUID? {
        
        switch self {
            
        case .initial, .stopped:
            return nil
            
        case .loading(let mediaId), .loaded(let mediaId), .playing(let mediaId), .paused(let mediaId, _), .finished(let mediaId), .failedLoad(let mediaId):
            return mediaId
        }
    }
}
