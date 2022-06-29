//
//  DefaultPlayerStateRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation

private struct PlayerStateDTO: Codable {

    var trackId: String
    var time: Int
    
    init(from domain: PlayerState) {
        
        self.trackId = domain.trackId.uuidString
        self.time = domain.time
    }
    
    func toDomain() -> PlayerState {
        return PlayerState(
            trackId: UUID(uuidString: trackId)!,
            time: time
        )
    }
}

private extension PlayerState {
    
    init(from dto: PlayerStateDTO) {
        
        self.trackId = UUID(uuidString: dto.trackId)!
        self.time = dto.time
    }
}

public final class DefaultPlayerStateRepository: PlayerStateRepository {

    private let keyValueStore: KeyValueStore
    private let key: String
    
    public init(keyValueStore: KeyValueStore, key: String) {
        
        self.keyValueStore = keyValueStore
        self.key = key
    }
    
    public func get() async -> Result<PlayerState?, PlayerStateRepositoryError> {
        
        let result = await keyValueStore.get(key: key, as: PlayerStateDTO.self)
        
        switch result {
            
        case .failure(let error):
            return .failure(.internalError(error))
            
        case .success(let value):
            return .success(value?.toDomain())
        }
    }
    
    public func put(state: PlayerState) async -> Result<Void, PlayerStateRepositoryError> {

        let dto = PlayerStateDTO(from: state)
        
        let result = await keyValueStore.put(
            key: key,
            value: dto
        )
        
        switch result {
            
        case .failure(let error):
            return .failure(.internalError(error))
            
        case .success:
            return .success(())
        }
    }
}
