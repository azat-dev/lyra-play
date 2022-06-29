//
//  AudioPlayerUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation

// MARK: - Interfaces

public enum AudioPlayerUseCaseError: Error {
    
    case trackNotFound
    case internalError(Error?)
    case noActiveTrack
}

public protocol AudioPlayerUseCase {
    
    func setTrack(fileId: UUID) async -> Result<Void, AudioPlayerUseCaseError>
    
    func getCurrentTrackId() async -> Result<UUID?, AudioPlayerUseCaseError>
    
    func play() async -> Result<Void, AudioPlayerUseCaseError>
    
    func pause() async -> Result<Void, AudioPlayerUseCaseError>
}

// MARK: - Implementations

public final class DefaultAudioPlayerUseCase: AudioPlayerUseCase {
    
    private let audioLibraryRepository: AudioLibraryRepository
    private let audioFilesRepository: FilesRepository
    private let playerStateRepository: PlayerStateRepository
    private let audioPlayerService: AudioPlayerService
    
    public init(
        audioLibraryRepository: AudioLibraryRepository,
        audioFilesRepository: FilesRepository,
        playerStateRepository: PlayerStateRepository,
        audioPlayerService: AudioPlayerService
    ) {
        
        self.audioLibraryRepository = audioLibraryRepository
        self.audioFilesRepository = audioFilesRepository
        self.playerStateRepository = playerStateRepository
        self.audioPlayerService = audioPlayerService
    }
    
    public func setTrack(fileId: UUID) async -> Result<Void, AudioPlayerUseCaseError> {
        
        let resultSearchFile = await audioLibraryRepository.getInfo(fileId: fileId)
        
        if case .failure = resultSearchFile {
            return .failure(.trackNotFound)
        }
        
        let playerState = PlayerState(
            trackId: fileId,
            time: 0
        )
        
        let result = await playerStateRepository.put(state: playerState)
        
        switch result {
            
        case .failure(let error):
            return .failure(.internalError(error))
            
        case .success:
            return .success(())
        }
    }
    
    public func getCurrentTrackId() async -> Result<UUID?, AudioPlayerUseCaseError> {
        
        let result = await playerStateRepository.get()
        
        switch result {
            
        case .failure(let error):
            return .failure(.internalError(error))
            
        case .success(let playerState):
            return .success(playerState?.trackId)
        }
    }
    
    public func play(trackId: UUID) async -> Result<Void, AudioPlayerUseCaseError> {

        do {
            
            let fileInfoResult = await audioLibraryRepository.getInfo(fileId: trackId)
            let fileInfo = try fileInfoResult.get()
            
            let fileDataResult = await audioFilesRepository.getFile(name: fileInfo.audioFile)
            let fileData = try fileDataResult.get()
            
            await audioPlayerService.play(trackId: trackId.uuidString, track: fileData)
            return .success(())
            
        } catch {
            return .failure(.internalError(error))
        }
    }
    
    public func play() async -> Result<Void, AudioPlayerUseCaseError> {
        let result = await getCurrentTrackId()

        switch result {
        case .success(let trackId):

            guard let trackId = trackId else {
                return .failure(.noActiveTrack)
            }

            return await play(trackId: trackId)
            
        case .failure(let error):
            
            return .failure(.internalError(error))
        }
        
        return .success(())
    }
    
    public func pause() async -> Result<Void, AudioPlayerUseCaseError> {
        return .success(())
    }
}