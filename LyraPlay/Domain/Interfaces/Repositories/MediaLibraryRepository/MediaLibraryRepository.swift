//
//  MediaLibraryRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public enum MediaLibraryRepositoryError: Error {
    
    case fileNotFound
    case nameMustBeUnique
    case parentNotFound
    case parentIsNotFolder
    case internalError(Error?)
}

public struct NewMediaLibraryFileData: Equatable {
    
    public var parentId: UUID?
    public var title: String
    public var subtitle: String?
    public var file: String
    public var image: String?
    public var genre: String?
    public var duration: Double

    public init(
        parentId: UUID?,
        title: String,
        subtitle: String?,
        file: String,
        duration: Double,
        image: String?,
        genre: String?
    ) {
        
        self.parentId = parentId
        self.title = title
        self.subtitle = subtitle
        self.file = file
        self.image = image
        self.genre = genre
        self.duration = duration
    }
}

public struct NewMediaLibraryFolderData: Equatable {
    
    public var parentId: UUID?
    public var title: String
    public var image: String?

    public init(
        parentId: UUID?,
        title: String,
        image: String?
    ) {
        
        self.parentId = parentId
        self.title = title
        self.image = image
    }
}


public protocol MediaLibraryRepositoryInput {
    
    func deleteItem(id: UUID) async -> Result<Void, MediaLibraryRepositoryError>
    
    func createFile(data: NewMediaLibraryFileData) async -> Result<MediaLibraryFile, MediaLibraryRepositoryError>
    
    func createFolder(data: NewMediaLibraryFolderData) async -> Result<MediaLibraryFolder, MediaLibraryRepositoryError>
    
    func updateFile(data: MediaLibraryFile) async -> Result<MediaLibraryFile, MediaLibraryRepositoryError>
    
    func updateFileProgress(id: UUID, time: TimeInterval) async -> Result<MediaLibraryFile, MediaLibraryRepositoryError>
    
    func updateFolder(data: MediaLibraryFolder) async -> Result<MediaLibraryFolder, MediaLibraryRepositoryError>
}

public protocol MediaLibraryRepositoryOutput {
    
    func listItems(folderId: UUID?) async -> Result<[MediaLibraryItem], MediaLibraryRepositoryError>
    
    func getItem(id: UUID) async -> Result<MediaLibraryItem, MediaLibraryRepositoryError>
}

public protocol MediaLibraryRepository: MediaLibraryRepositoryOutput, MediaLibraryRepositoryInput {}
