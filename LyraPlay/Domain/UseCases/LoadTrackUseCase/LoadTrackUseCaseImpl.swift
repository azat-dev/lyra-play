//
//  LoadTrackUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public final class LoadTrackUseCaseImpl: LoadTrackUseCase {
    
    // MARK: - Properties
    
    private let audioLibraryRepository: AudioLibraryRepository
    private let audioFilesRepository: FilesRepository
    
    // MARK: - Initializers
    
    public init(
        audioLibraryRepository: AudioLibraryRepository,
        audioFilesRepository: FilesRepository
    ) {
        
        self.audioLibraryRepository = audioLibraryRepository
        self.audioFilesRepository = audioFilesRepository
    }
}

// MARK: - Input Methods

extension LoadTrackUseCaseImpl {
    
    public func load(trackId: UUID) async -> Result<Data, LoadTrackUseCaseError> {
        
        let resultLibraryItem = await audioLibraryRepository.getInfo(fileId: trackId)
        
        guard case.success(let libraryItem) = resultLibraryItem else {
            return .failure(resultLibraryItem.error!.map())
        }
        
        let resultAudioFile = await audioFilesRepository.getFile(name: libraryItem.audioFile)
        
        guard case .success(let audioData) = resultAudioFile else {
            return .failure(resultAudioFile.error!.map())
        }
        
        return .success(audioData)
    }
}

// MARK: - Error Mappings

fileprivate extension AudioLibraryRepositoryError {
    
    func map() -> LoadTrackUseCaseError {
        
        switch self {
        case .fileNotFound:
            return .trackNotFound
            
        case .internalError(let err):
            return.internalError(err)
        }
    }
}

fileprivate extension FilesRepositoryError {
    
    func map() -> LoadTrackUseCaseError {
        
        switch self {
            
        case .fileNotFound:
            return .trackNotFound
            
        case .internalError(let err):
            return.internalError(err)
        }
    }
}
