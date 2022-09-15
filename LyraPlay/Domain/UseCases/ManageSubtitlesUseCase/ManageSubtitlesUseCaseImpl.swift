//
//  ManageSubtitlesUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation

public final class ManageSubtitlesUseCaseImpl: ManageSubtitlesUseCase {

    // MARK: - Properties

    private let subtitlesRepository: SubtitlesRepository
    private let subtitlesFilesRepository: FilesRepository

    // MARK: - Initializers

    public init(
        subtitlesRepository: SubtitlesRepository,
        subtitlesFilesRepository: FilesRepository
    ) {

        self.subtitlesRepository = subtitlesRepository
        self.subtitlesFilesRepository = subtitlesFilesRepository
    }
}

// MARK: - Input Methods

extension ManageSubtitlesUseCaseImpl {

    public func deleteItem(mediaId: UUID, language: String) async -> Result<Void, ManageSubtitlesUseCaseError> {

        let fetchResult = await subtitlesRepository.fetch(mediaFileId: mediaId, language: language)
        
        guard case .success(let subtitlesItem) = fetchResult else {
            
            return .failure(fetchResult.error!.map())
        }
        
        let result = await subtitlesRepository.delete(mediaFileId: mediaId, language: language)
        
        guard case .success = result else {
            
            return .failure(result.error!.map())
        }
        
        let _ = await subtitlesFilesRepository.deleteFile(name: subtitlesItem.file)
        return .success(())
    }
    
    public func deleteAllFor(mediaId: UUID) async -> Result<Void, ManageSubtitlesUseCaseError> {
        
        let fetchResult = await subtitlesRepository.list(mediaFileId: mediaId)
        
        guard case .success(let items) = fetchResult else {
            return .failure(fetchResult.error!.map())
        }
        
        for item in items {
            
            let _ = await subtitlesFilesRepository.deleteFile(name: item.file)
            let _ = await subtitlesRepository.delete(mediaFileId: mediaId, language: item.language)
        }
        
        return .success(())
    }
}

// MARK: - Output Methods

extension ManageSubtitlesUseCaseImpl {

}

// MARK: Error Mappings

fileprivate extension SubtitlesRepositoryError {

    func map() -> ManageSubtitlesUseCaseError {

        switch self {

            case .itemNotFound:
                return .itemNotFound

            case .internalError(let error):
                return .internalError(error)
        }
    }
}

fileprivate extension FilesRepositoryError {

    func map() -> ManageSubtitlesUseCaseError {

        switch self {

            case .fileNotFound:
                return .internalError(nil)

            case .internalError(let error):
                return .internalError(error)
        }
    }
}
