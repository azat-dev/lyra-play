//
//  ShowMediaInfoUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 02.07.22.
//

import Foundation

// MARK: - Interfaces

public struct MediaInfo {
    
    public var id: String
    public var coverImage: Data
    public var title: String?
    public var artist: String?
    public var duration: Double
}

public enum ShowMediaInfoUseCaseError: Error {
    
    case trackNotFound
    case internalError(Error?)
}

public protocol ShowMediaInfoUseCase {
    
    func fetchInfo(trackId: UUID) async -> Result<MediaInfo, ShowMediaInfoUseCaseError>
}

// MARK: - Implementations


public final class DefaultShowMediaInfoUseCase: ShowMediaInfoUseCase {
    
    private var audioLibraryRepository: AudioLibraryRepository
    private var imagesRepository: FilesRepository
    private var defaultImage: Data
    
    public var mediaInfo: Observable<MediaInfo?> = Observable(nil)
    
    public init(
        audioLibraryRepository: AudioLibraryRepository,
        imagesRepository: FilesRepository,
        defaultImage: Data
    ) {
        
        self.audioLibraryRepository = audioLibraryRepository
        self.imagesRepository = imagesRepository
        self.defaultImage = defaultImage
    }
    
    private func mapAudioLibraryError(_ error: AudioLibraryRepositoryError) -> ShowMediaInfoUseCaseError {
        
        switch error {
        case .fileNotFound:
            return .trackNotFound
            
        case .internalError(let error):
            return .internalError(error)
        }
    }
    
    public func fetchInfo(trackId: UUID) async -> Result<MediaInfo, ShowMediaInfoUseCaseError> {
        
        let fileInfoResult = await audioLibraryRepository.getInfo(fileId: trackId)
        
        guard case .success(let fileInfo) = fileInfoResult else {
            
            let mappedError = mapAudioLibraryError(fileInfoResult.error!)
            return .failure(mappedError)
        }
        
        var coverImage = defaultImage
        
        if let coverImageName = fileInfo.coverImage {
            
            let imageData = try? await imagesRepository.getFile(name: coverImageName).get()
            coverImage = imageData ?? coverImage
        }
        
        let mediaInfo = MediaInfo(
            id: fileInfo.id!.uuidString,
            coverImage: coverImage,
            title: fileInfo.name,
            artist: fileInfo.artist ?? "",
            duration: fileInfo.duration
        )
        
        self.mediaInfo.value = mediaInfo
        return .success(mediaInfo)
    }
}
