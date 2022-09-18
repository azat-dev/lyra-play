//
//  EditMediaLibraryListUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.09.2022.
//

import Foundation

public final class EditMediaLibraryListUseCaseImpl: EditMediaLibraryListUseCase {
    
    // MARK: - Properties
    
    private let mediaLibraryRepository: MediaLibraryRepository
    private let mediaFilesRepository: FilesRepository
    private let manageSubtitlesUseCase: ManageSubtitlesUseCase
    private let imagesRepository: FilesRepository
    
    // MARK: - Initializers
    
    public init(
        mediaLibraryRepository: MediaLibraryRepository,
        mediaFilesRepository: FilesRepository,
        manageSubtitlesUseCase: ManageSubtitlesUseCase,
        imagesRepository: FilesRepository
    ) {
        
        self.mediaLibraryRepository = mediaLibraryRepository
        self.mediaFilesRepository = mediaFilesRepository
        self.manageSubtitlesUseCase = manageSubtitlesUseCase
        self.imagesRepository = imagesRepository
    }
}

// MARK: - Input Methods

extension EditMediaLibraryListUseCaseImpl {
    
    public func deleteItem(itemId: UUID) async -> Result<Void, EditMediaLibraryListUseCaseError> {
        
        let resultGetItem = await mediaLibraryRepository.getInfo(fileId: itemId)
        
        guard case .success(let mediaItem) = resultGetItem else {
            return .failure(resultGetItem.error!.map())
        }
        
        let resultDeleteMedia = await mediaLibraryRepository.delete(fileId: itemId)
        
        guard case .success = resultDeleteMedia else {
            return .failure(resultDeleteMedia.error!.map())
        }
        
        let _ = await mediaFilesRepository.deleteFile(name: mediaItem.audioFile)
        
        if let coverImage = mediaItem.coverImage {
            let _ = await imagesRepository.deleteFile(name: coverImage)
        }
        
        let _ = await manageSubtitlesUseCase.deleteAllFor(mediaId: itemId)
        return .success(())
    }
}

// MARK: - Output Methods

extension EditMediaLibraryListUseCaseImpl {
    
}

// MARK: Error Mappings

fileprivate extension FilesRepositoryError {
    
    func map() -> EditMediaLibraryListUseCaseError {
        
        switch self {
            
        case .fileNotFound:
            return .internalError(nil)
            
        case .internalError(let error):
            return .internalError(error)
        }
    }
}

fileprivate extension SubtitlesRepositoryError {
    
    func map() -> EditMediaLibraryListUseCaseError {
        
        switch self {
            
        case .itemNotFound:
            return .itemNotFound
            
        case .internalError(let error):
            return .internalError(error)
        }
    }
}

fileprivate extension MediaLibraryRepositoryError {
    
    func map() -> EditMediaLibraryListUseCaseError {
        
        switch self {
            
        case .parentNotFound, .nameMustBeUnique, .parentIsNotFolder:
            return .internalError(nil)
            
        case .fileNotFound:
            return .itemNotFound
            
        case .internalError(let error):
            return .internalError(error)
        }
    }
}
