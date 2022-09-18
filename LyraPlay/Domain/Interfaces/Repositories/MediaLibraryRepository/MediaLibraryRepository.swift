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
    case internalError(Error?)
}

public struct NewMediaLibraryFileData: Equatable {
    
    public var parentId: UUID?
    public var title: String
    public var subtitle: String
    public var file: String
    public var image: String?
    public var genre: String?
    public var duration: Double

    public init(
        parentId: UUID?,
        title: String,
        subtitle: String,
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


public protocol MediaLibraryRepositoryInput {
    
    func putFile(info: MediaLibraryAudioFile) async -> Result<MediaLibraryAudioFile, MediaLibraryRepositoryError>
    
    func delete(fileId: UUID) async -> Result<Void, MediaLibraryRepositoryError>
    
    func createFile(data: NewMediaLibraryFileData) async -> Result<MediaLibraryFile, MediaLibraryRepositoryError>
}

public protocol MediaLibraryRepositoryOutput {
    
    func listFiles() async -> Result<[MediaLibraryAudioFile], MediaLibraryRepositoryError>
    
    func getInfo(fileId: UUID) async -> Result<MediaLibraryAudioFile, MediaLibraryRepositoryError>
    
    func getItem(id: UUID) async -> Result<MediaLibraryItem, MediaLibraryRepositoryError>
}

public protocol MediaLibraryRepository: MediaLibraryRepositoryOutput, MediaLibraryRepositoryInput {}
