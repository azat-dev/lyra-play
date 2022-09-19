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
    
    private func deleteFile(data: MediaLibraryFile) async -> Result<Void, EditMediaLibraryListUseCaseError> {
        
        let _ = await mediaFilesRepository.deleteFile(name: data.file)
        
        if let coverImage = data.image {
            let _ = await imagesRepository.deleteFile(name: coverImage)
        }
        
        let _ = await manageSubtitlesUseCase.deleteAllFor(mediaId: data.id)
        
        return .success(())
    }
    
    private func deleteFolder(data: MediaLibraryFolder) async -> Result<Void, EditMediaLibraryListUseCaseError> {
        
        if let coverImage = data.image {
            let _ = await imagesRepository.deleteFile(name: coverImage)
        }
        
        return .success(())
    }
    
    public func deleteItem(id itemId: UUID) async -> Result<Void, EditMediaLibraryListUseCaseError> {
        
        let resultGetItem = await mediaLibraryRepository.getItem(id: itemId)
        
        guard case .success(let mediaItem) = resultGetItem else {
            return .failure(resultGetItem.error!.map())
        }
        
        let resultDeleteMedia = await mediaLibraryRepository.deleteItem(id: itemId)
        
        guard case .success = resultDeleteMedia else {
            return .failure(resultDeleteMedia.error!.map())
        }
        
        switch mediaItem {
            
        case .file(let fileData):
            return await deleteFile(data: fileData)
            
        case .folder(let data):
            return await deleteFolder(data: data)
        }
    }
}

// MARK: - Error Mappings

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
