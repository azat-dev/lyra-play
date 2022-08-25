//
//  LoadTrackUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 02.07.22.
//

import Foundation

// MARK: - Interfaces

public enum LoadTrackUseCaseError: Error {
    
    case trackNotFound
    case internalError(Error?)
}

public protocol LoadTrackUseCase {
    
    func load(trackId: UUID) async -> Result<Data, LoadTrackUseCaseError>
}

// MARK: - Implementations

public final class LoadTrackUseCaseImpl: LoadTrackUseCase {
    
    private let audioLibraryRepository: AudioLibraryRepository
    private let audioFilesRepository: FilesRepository
    
    public init(
        audioLibraryRepository: AudioLibraryRepository,
        audioFilesRepository: FilesRepository
    ) {
        
        self.audioLibraryRepository = audioLibraryRepository
        self.audioFilesRepository = audioFilesRepository
    }
    

    private func mapLibraryError(_ error: AudioLibraryRepositoryError) -> LoadTrackUseCaseError {
        
        switch error {
        case .fileNotFound:
            return .trackNotFound
            
        case .internalError(let err):
            return.internalError(err)
        }
    }
    
    private func mapFilesError(_ error: FilesRepositoryError) -> LoadTrackUseCaseError {
        
        switch error {
        case .fileNotFound:
            return .trackNotFound
            
        case .internalError(let err):
            return.internalError(err)
        }
    }
    
    public func load(trackId: UUID) async -> Result<Data, LoadTrackUseCaseError> {
        
        let resultLibraryItem = await audioLibraryRepository.getInfo(fileId: trackId)
        
        guard case.success(let libraryItem) = resultLibraryItem else {
            let mappedError = mapLibraryError(resultLibraryItem.error!)
            return .failure(mappedError)
        }
        
        let resultAudioFile = await audioFilesRepository.getFile(name: libraryItem.audioFile)
        
        guard case .success(let audioData) = resultAudioFile else {
            let mappedError = mapFilesError(resultAudioFile.error!)
            return .failure(mappedError)
        }
        
        return .success(audioData)
    }
}
