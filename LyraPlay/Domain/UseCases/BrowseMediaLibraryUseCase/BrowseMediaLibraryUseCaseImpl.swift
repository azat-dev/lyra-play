//
//  BrowseMediaLibraryUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public final class BrowseMediaLibraryUseCaseImpl: BrowseMediaLibraryUseCase {
    
    // MARK: - Properties
    
    private let mediaLibraryRepository: MediaLibraryRepository
    private let imagesRepository: FilesRepository
    
    // MARK: - Initializers
    
    public init(
        mediaLibraryRepository: MediaLibraryRepository,
        imagesRepository: FilesRepository
    ) {
        
        self.mediaLibraryRepository = mediaLibraryRepository
        self.imagesRepository = imagesRepository
    }
    
}

// MARK: - Input Methods

extension BrowseMediaLibraryUseCaseImpl {}

// MARK: - Output Methods

extension BrowseMediaLibraryUseCaseImpl {
    
    public func listFiles() async -> Result<[MediaLibraryAudioFile], BrowseMediaLibraryUseCaseError> {
        
        let result = await mediaLibraryRepository.listFiles()
        
        switch result {
        case .success(let files):
            return .success(files)
            
        case .failure(let error):
            return .failure(error.map())
        }
    }
    
    public func getFileInfo(fileId: UUID) async -> Result<MediaLibraryAudioFile, BrowseMediaLibraryUseCaseError> {
        
        let result = await mediaLibraryRepository.getInfo(fileId: fileId)
        
        switch result {
        case .success(let file):
            return .success(file)
            
        case .failure(let error):
            return .failure(error.map())
        }
    }
    
    public func fetchImage(name: String) async -> Result<Data, BrowseMediaLibraryUseCaseError> {
        
        let result = await imagesRepository.getFile(name: name)
        
        switch result {
            
        case .failure(let error):
            guard case .fileNotFound = error else {
                return .failure(.internalError)
            }
            
            return .failure(.fileNotFound)
            
        case .success(let imageData):
            return .success(imageData)
        }
    }
}
// MARK: - Error Mappings

fileprivate extension MediaLibraryRepositoryError {
    
    func map() -> BrowseMediaLibraryUseCaseError {
        
        switch self {
        case .fileNotFound:
            return .fileNotFound
        case .internalError:
            return .internalError
        }
    }
}
