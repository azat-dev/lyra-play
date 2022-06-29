//
//  PlayerStateRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation

public protocol PlayerStateRepository {
    
    func put(state: PlayerState) async -> Result<Void, AudioPlayerUseCaseError>
    func get() async -> Result<PlayerState, AudioPlayerUseCaseError>
}
