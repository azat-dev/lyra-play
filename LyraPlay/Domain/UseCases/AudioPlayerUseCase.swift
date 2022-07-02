//
//  AudioPlayerUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation
import UIKit

// MARK: - Interfaces

public struct ExpandedAudioFileInfo {
    
    var id: UUID
    var coverImage: Data
    var title: String?
    var artist: String?
    var duration: Double
}

public enum AudioPlayerUseCaseError: Error {
    
    case trackNotFound
    case internalError(Error?)
    case noActiveTrack
}

public protocol AudioPlayerUseCaseOutput {
    
    var isPlaying: Observable<Bool> { get }
    var audioFileInfo: Observable<ExpandedAudioFileInfo?> { get }
}

public protocol AudioPlayerUseCaseInput {
    
    func setTrack(fileId: UUID) async -> Result<Void, AudioPlayerUseCaseError>
    
    func getCurrentTrackId() async -> Result<UUID?, AudioPlayerUseCaseError>
    
    func play() async -> Result<Void, AudioPlayerUseCaseError>
    
    func pause() async -> Result<Void, AudioPlayerUseCaseError>
}

public protocol AudioPlayerUseCase: AudioPlayerUseCaseInput, AudioPlayerUseCaseOutput {
    
}

// MARK: - Implementations

public final class DefaultAudioPlayerUseCase: AudioPlayerUseCase {
    
    private let audioLibraryRepository: AudioLibraryRepository
    private let audioFilesRepository: FilesRepository
    private let imagesRepository: FilesRepository
    private let playerStateRepository: PlayerStateRepository
    private let audioPlayerService: AudioPlayerService
    
    public var isPlaying: Observable<Bool> = Observable(false)
    public var currentAudioFileInfo: Observable<ExpandedAudioFileInfo?> = Observable(nil)
    public var audioFileInfo: Observable<ExpandedAudioFileInfo?>
    
    public init(
        audioLibraryRepository: AudioLibraryRepository,
        audioFilesRepository: FilesRepository,
        imagesRepository: FilesRepository,
        playerStateRepository: PlayerStateRepository,
        audioPlayerService: AudioPlayerService
    ) {
        
        self.audioLibraryRepository = audioLibraryRepository
        self.audioFilesRepository = audioFilesRepository
        self.imagesRepository = imagesRepository
        self.playerStateRepository = playerStateRepository
        self.audioPlayerService = audioPlayerService
        
        self.audioFileInfo = Observable(nil)
        syncMediaInfoWithAudioService()
    }
    
    private func getDefaultCoverImage() async -> Data {
        return UIImage(systemName: "lock")!.pngData()!
    }
    
    private func getCoverImage(name: String?) async -> Data {
        
        guard let name = name else {
            return await getDefaultCoverImage()
        }
        
        let imageDataResult = await imagesRepository.getFile(name: name)
        
        if let image = try? imageDataResult.get() {
            return image
        }
        
        return await getDefaultCoverImage()
    }
    
    private func syncMediaInfoWithAudioService() {
        
//
//            guard let self = self else {
//                return
//            }
//
//            guard let audioFileInfo = audioFileInfo else {
//                return
//            }
//
//            Task {
//                let coverImage = await self.getCoverImage(name: audioFileInfo.name)
//
//                let mediaInfo = MediaInfo(
//                    title: audioFileInfo.name,
//                    artist: audioFileInfo.artist ?? "",
//                    coverImage: coverImage
//                )
//
//                await self.audioPlayerService.updateMediaInfo(mediaInfo)
//            }
//        }
    }
    
    private func updateCurrentFileInfo(audioFileInfo: AudioFileInfo?) async {
        
        guard let audioFileInfo = audioFileInfo else {
            currentAudioFileInfo.value = nil
            return
        }

        let expandedInfo = ExpandedAudioFileInfo(
            id: audioFileInfo.id!,
            coverImage: await getCoverImage(name: audioFileInfo.coverImage),
            duration: audioFileInfo.duration
        )
        
        currentAudioFileInfo.value = expandedInfo
    }
    
    public func setTrack(fileId: UUID) async -> Result<Void, AudioPlayerUseCaseError> {
        
        let resultFileInfo = await audioLibraryRepository.getInfo(fileId: fileId)
        
        guard case .success(let fileInfo) = resultFileInfo else {
            return .failure(.trackNotFound)
        }
        
        await updateCurrentFileInfo(audioFileInfo: fileInfo)
        
        let playerState = PlayerState(
            trackId: fileId,
            time: 0
        )
        
        let result = await playerStateRepository.put(state: playerState)
        
        return result.mapError { error in .internalError(error) }
    }
    
    public func getCurrentTrackId() async -> Result<UUID?, AudioPlayerUseCaseError> {
        
        let result = await playerStateRepository.get()
        
        return result.map { state in state?.trackId }
            .mapError { error in .internalError(error) }
    }
    
    public func play(trackId: UUID) async -> Result<Void, AudioPlayerUseCaseError> {

        do {
            
            let fileInfoResult = await audioLibraryRepository.getInfo(fileId: trackId)
            let fileInfo = try fileInfoResult.get()
            
            let fileDataResult = await audioFilesRepository.getFile(name: fileInfo.audioFile)
            
            var imageData = UIImage(systemName: "lock")!.pngData()!
            
            if let coverImage = fileInfo.coverImage {
                
                let imageDataResult = await imagesRepository.getFile(name: coverImage)
                if case .success(let data) = imageDataResult {
                    imageData = data
                }
            }
            
            let fileData = try fileDataResult.get()
            
            let mediaInfo = MediaInfo(
                id: trackId.uuidString,
                title: fileInfo.name,
                artist: fileInfo.artist ?? "",
                coverImage: imageData,
                duration: fileInfo.duration
            )
            
            let resultPlay = await audioPlayerService.play(mediaInfo: mediaInfo, data: fileData)
            guard case .success = resultPlay else {
                return .failure(.internalError(nil))
            }
            
            isPlaying.value = true
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

            isPlaying.value = true
            return await play(trackId: trackId)
            
        case .failure(let error):
            
            return .failure(.internalError(error))
        }
    }
    
    public func pause() async -> Result<Void, AudioPlayerUseCaseError> {
        
        let result = await audioPlayerService.pause()
        
        guard case .success = result else {
            return .failure(.internalError(nil))
        }
        
        isPlaying.value = false
        return .success(())
    }
}
