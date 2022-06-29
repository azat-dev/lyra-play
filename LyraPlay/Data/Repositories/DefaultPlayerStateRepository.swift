//
//  DefaultPlayerStateRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation

struct PlayerStateDTO: Codable {

    var trackId: String
    var time: Int
    
    init(from domain: PlayerState) {
        
        self.trackId = domain.trackId.uuidString
        self.time = domain.time
    }
}

private extension PlayerState {
    
    init(from dto: PlayerStateDTO) {
        
        self.trackId = UUID(uuidString: dto.trackId)!
        self.time = dto.time
    }
}

final class DefaultPlayerStateRepository: PlayerStateRepository {
    
    private static let KEY = "last-player-state"
    
    func get() async -> Result<PlayerState?, AudioPlayerUseCaseError> {
        
        guard let encodedDTO = UserDefaults.string(forKey: KEY) else {
            return .success(nil)
        }
        
    }
    
    func put(state: PlayerState) async -> Result<Void, AudioPlayerUseCaseError> {
        
        let dto = PlayerStateDTO(from: state)
        let encoder = JSONEncoder()
        
        let encodedDTO = try! encoder.encode(dto)
        
        UserDefaults.set(encodedDTO, forKey: KEY)
        return .success(())
    }
}
