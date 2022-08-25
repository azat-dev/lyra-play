//
//  PlayerStateRepositoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation

private struct LastPlayerStateDTO: Codable {

    var trackId: String
    var time: Int
    
    init(from domain: LastPlayerState) {
        
        self.trackId = domain.trackId.uuidString
        self.time = domain.time
    }
    
    func toDomain() -> LastPlayerState {
        return LastPlayerState(
            trackId: UUID(uuidString: trackId)!,
            time: time
        )
    }
}

private extension LastPlayerState {
    
    init(from dto: LastPlayerStateDTO) {
        
        self.trackId = UUID(uuidString: dto.trackId)!
        self.time = dto.time
    }
}

public final class PlayerStateRepositoryImpl: PlayerStateRepository {

    private let keyValueStore: KeyValueStore
    private let key: String
    
    public init(keyValueStore: KeyValueStore, key: String) {
        
        self.keyValueStore = keyValueStore
        self.key = key
    }
    
    public func get() async -> Result<LastPlayerState?, PlayerStateRepositoryError> {
        
        let result = await keyValueStore.get(key: key, as: LastPlayerStateDTO.self)
        
        switch result {
            
        case .failure(let error):
            return .failure(.internalError(error))
            
        case .success(let value):
            return .success(value?.toDomain())
        }
    }
    
    public func put(state: LastPlayerState) async -> Result<Void, PlayerStateRepositoryError> {

        let dto = LastPlayerStateDTO(from: state)
        
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
