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
    private let subtitlesRepository: SubtitlesRepository
    private let imagesRepository: FilesRepository

    // MARK: - Initializers

    public init(
        mediaLibraryRepository: MediaLibraryRepository,
        mediaFilesRepository: FilesRepository,
        subtitlesRepository: SubtitlesRepository,
        imagesRepository: FilesRepository
    ) {

        self.mediaLibraryRepository = mediaLibraryRepository
        self.mediaFilesRepository = mediaFilesRepository
        self.subtitlesRepository = subtitlesRepository
        self.imagesRepository = imagesRepository
    }
}

// MARK: - Input Methods

extension EditMediaLibraryListUseCaseImpl {

    public func deleteItem(itemId: UUID) async -> Result<Void, EditMediaLibraryListUseCaseError> {

        fatalError()
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
