//
//  PlayerStateRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation

public enum PlayerStateRepositoryError: Error {
    
    case internalError(Error?)
}

public protocol PlayerStateRepository {
    
    func put(state: LastPlayerState) async -> Result<Void, PlayerStateRepositoryError>
    
    func get() async -> Result<LastPlayerState?, PlayerStateRepositoryError>
}
