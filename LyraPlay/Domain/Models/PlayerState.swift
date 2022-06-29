//
//  PlayerState.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation

public struct PlayerState {

    public var trackId: UUID
    public var time: Int
    
    public init(trackId: UUID, time: Int) {
        self.trackId = trackId
        self.time = time
    }
}
