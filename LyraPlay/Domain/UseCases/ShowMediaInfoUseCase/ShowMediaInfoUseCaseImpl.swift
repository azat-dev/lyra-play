//
//  ShowMediaInfoUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class ShowMediaInfoUseCaseImpl: ShowMediaInfoUseCase {
    
    // MARK: - Properties
    
    private let mediaLibraryRepository: MediaLibraryRepository
    private let imagesRepository: FilesRepository
    private let defaultImage: Data
    
    // MARK: - Initializers
    
    public init(
        mediaLibraryRepository: MediaLibraryRepository,
        imagesRepository: FilesRepository,
        defaultImage: Data
    ) {
        
        self.mediaLibraryRepository = mediaLibraryRepository
        self.imagesRepository = imagesRepository
        self.defaultImage = defaultImage
    }
    
}

// MARK: - Output Methods

extension ShowMediaInfoUseCaseImpl {
    
    public func fetchInfo(trackId: UUID) async -> Result<MediaInfo, ShowMediaInfoUseCaseError> {
        
        let fileInfoResult = await mediaLibraryRepository.getInfo(fileId: trackId)
        
        guard case .success(let fileInfo) = fileInfoResult else {
            
            return .failure(fileInfoResult.error!.map())
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
        
        return .success(mediaInfo)
    }
}

// MARK: - Error Mapping

fileprivate extension MediaLibraryRepositoryError {
    
    func map() -> ShowMediaInfoUseCaseError {
        
        switch self {
            
        case .parentNotFound, .nameMustBeUnique, .parentIsNotFolder:
            return .internalError(nil)
            
        case .fileNotFound:
            return .trackNotFound
            
        case .internalError(let error):
            return .internalError(error)
        }
    }
}
