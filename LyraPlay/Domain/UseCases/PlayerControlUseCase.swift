//
//  PlayerControlUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation
import UIKit

// MARK: - Interfaces

public enum PlayerControlUseCaseError: Error {
    
    case trackNotFound
    case internalError(Error?)
    case noActiveTrack
}

public protocol PlayerControlUseCaseOutput {
    
    var isPlaying: Observable<Bool> { get }
}

public protocol PlayerControlUseCaseInput {
    
    func setTrack(fileId: UUID) async -> Result<Void, PlayerControlUseCaseError>
    
    func getCurrentTrackId() async -> Result<UUID?, PlayerControlUseCaseError>
    
    func play() async -> Result<Void, PlayerControlUseCaseError>
    
    func pause() async -> Result<Void, PlayerControlUseCaseError>
}

public protocol PlayerControlUseCase: PlayerControlUseCaseInput, PlayerControlUseCaseOutput {
    
}

// MARK: - Implementations

public final class DefaulPlayerControlUseCase: PlayerControlUseCase {
    public func setTrack(fileId: UUID) async -> Result<Void, PlayerControlUseCaseError> {
        return .success(())
    }
    
    public func getCurrentTrackId() async -> Result<UUID?, PlayerControlUseCaseError> {
        return .success(nil)
    }
    
    public func play() async -> Result<Void, PlayerControlUseCaseError> {
        return .success(())
    }
    
    public func pause() async -> Result<Void, PlayerControlUseCaseError> {
        return .success(())
    }
    
    
    
    public init() {}
//    private let showMediaInfoUseCase: ShowMediaInfoUseCase
//    private let audioLibraryRepository: AudioLibraryRepository
//    private let audioFilesRepository: FilesRepository
//    private let imagesRepository: FilesRepository
//    private let playerStateRepository: PlayerStateRepository
//    private let audioService: AudioService
//    private let showMediaInfoUseCase: ShowMediaInfoUseCase
//    
    public var isPlaying: Observable<Bool> = Observable(false)
//    
//    public init(
//        showMediaInfoUseCase: ShowMediaInfoUseCase,
//        loadAudioTrackUseCa
//        audioLibraryRepository: AudioLibraryRepository,
//        audioFilesRepository: FilesRepository,
//        imagesRepository: FilesRepository,
//        playerStateRepository: PlayerStateRepository,
//        audioService: AudioService
//    ) {
//        
//        self.audioLibraryRepository = audioLibraryRepository
//        self.audioFilesRepository = audioFilesRepository
//        self.imagesRepository = imagesRepository
//        self.playerStateRepository = playerStateRepository
//        self.audioService = audioService
//        
//        syncMediaInfoWithAudioService()
//    }
//    
//    private func getDefaultCoverImage() async -> Data {
//        return UIImage(systemName: "lock")!.pngData()!
//    }
//    
//
//    
//    private func syncMediaInfoWithAudioService() {
//        
////
////            guard let self = self else {
////                return
////            }
////
////            guard let audioFileInfo = audioFileInfo else {
////                return
////            }
////
////            Task {
////                let coverImage = await self.getCoverImage(name: audioFileInfo.name)
////
////                let mediaInfo = MediaInfo(
////                    title: audioFileInfo.name,
////                    artist: audioFileInfo.artist ?? "",
////                    coverImage: coverImage
////                )
////
////                await self.audioService.updateMediaInfo(mediaInfo)
////            }
////        }
//    }
//    
////    public func setTrack(fileId: UUID) async -> Result<Void, PlayerControlUseCaseError> {
////
////        let resultFileInfo = await audioLibraryRepository.getInfo(fileId: fileId)
////
////        guard case .success(let fileInfo) = resultFileInfo else {
////            return .failure(.trackNotFound)
////        }
////
////        await updateCurrentFileInfo(audioFileInfo: fileInfo)
////
////        let playerState = PlayerState(
////            trackId: fileId,
////            time: 0
////        )
////
////        let result = await playerStateRepository.put(state: playerState)
////
////        return result.mapError { error in .internalError(error) }
////    }
//    
//    public func getCurrentTrackId() async -> Result<UUID?, PlayerControlUseCaseError> {
//        
//        let result = await playerStateRepository.get()
//        
//        return result.map { state in state?.trackId }
//            .mapError { error in .internalError(error) }
//    }
//    
//    public func play(trackId: UUID) async -> Result<Void, PlayerControlUseCaseError> {
//
//        do {
//            
//            let fileInfoResult = await audioLibraryRepository.getInfo(fileId: trackId)
//            let fileInfo = try fileInfoResult.get()
//            let fileDataResult = await audioFilesRepository.getFile(name: fileInfo.audioFile)
//
//            audioService.play(mediaInfo: <#T##MediaInfo#>, data: <#T##Data#>)
//            let resultPlay = await audioService.play(mediaInfo: mediaInfo, data: fileData)
//            
//            let mediaInfo = showMediaInfoUseCase.setTrack(trackId: trackId)
//            
//            if let coverImage = fileInfo.coverImage {
//                
//                let imageDataResult = await imagesRepository.getFile(name: coverImage)
//                if case .success(let data) = imageDataResult {
//                    imageData = data
//                }
//            }
//            
//            let fileData = try fileDataResult.get()
//            
//            
//
//            guard case .success = resultPlay else {
//                return .failure(.internalError(nil))
//            }
//            
//            isPlaying.value = true
//            return .success(())
//            
//        } catch {
//            return .failure(.internalError(error))
//        }
//    }
//    
//    public func play() async -> Result<Void, PlayerControlUseCaseError> {
//        
//        let result = await getCurrentTrackId()
//
//        switch result {
//            
//        case .success(let trackId):
//
//            guard let trackId = trackId else {
//                return .failure(.noActiveTrack)
//            }
//
//            isPlaying.value = true
//            return await play(trackId: trackId)
//            
//        case .failure(let error):
//            
//            return .failure(.internalError(error))
//        }
//    }
//    
//    public func pause() async -> Result<Void, PlayerControlUseCaseError> {
//        
//        let result = await audioService.pause()
//        
//        guard case .success = result else {
//            return .failure(.internalError(nil))
//        }
//        
//        isPlaying.value = false
//        return .success(())
//    }
}
