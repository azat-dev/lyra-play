////
////  AudioPlayerUseCase.swift
////  LyraPlay
////
////  Created by Azat Kaiumov on 29.06.22.
////
//
//import Foundation
//
//// MARK: - Interfaces
//
//public enum AudioPlayerUseCaseError: Error {
//    
//    case trackNotFound
//    case internalError(Error?)
//}
//
//public protocol AudioPlayerUseCase {
//    
//    func setTrack(fileId: UUID) async -> Result<Void, AudioPlayerUseCaseError>
//    func getCurrentTrackId(fileId: UUID) async -> Result<UUID, AudioPlayerUseCaseError>
//}
//
//// MARK: - Implementations
//
//public final class DefaultAudioPlayerUseCase: AudioPlayerUseCase {
//    
//    private let audioFilesRepository: AudioFilesRepository
//    private let playerStateRepository: PlayerStateRepository
//    
//    public init(
//        audioFilesRepository: AudioFilesRepository,
//        playerStateRepository: PlayerStateRepository
//    ) {
//        
//        self.audioFilesRepository = audioFilesRepository
//        self.playerStateRepository = playerStateRepository
//    }
//    
//    public func setTrack(fileId: UUID) async -> Result<Void, AudioPlayerUseCaseError> {
//        
//        let playerState = PlayerState(
//            trackId: fileId,
//            time: 0
//        )
//        
//        let result = await playerStateRepository.put(state: playerState)
//        
//        switch result {
//            
//        case .failure(let error):
//            return .failure(.internalError(error))
//            
//        case .success:
//            return .success(())
//        }
//    }
//    
//    func getCurrentTrackId(fileId: UUID) async -> Result<UUID, AudioPlayerUseCaseError> {
//        
//        let result = await playerStateRepository.get()
//        
//        switch result {
//            
//        case .failure(let error):
//            return .failure(.internalError(error))
//            
//        case .success(let playerState):
//            return .success(playerState.trackId)
//        }
//    }
//}
