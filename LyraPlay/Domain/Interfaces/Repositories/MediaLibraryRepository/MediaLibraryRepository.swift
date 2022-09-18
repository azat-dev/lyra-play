//
//  MediaLibraryRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public enum MediaLibraryRepositoryError: Error {
    
    case fileNotFound
    case internalError(Error?)
}

public protocol MediaLibraryRepositoryInput {
    
    func putFile(info: MediaLibraryAudioFile) async -> Result<MediaLibraryAudioFile, MediaLibraryRepositoryError>
    
    func delete(fileId: UUID) async -> Result<Void, MediaLibraryRepositoryError>
}

public protocol MediaLibraryRepositoryOutput {
    
    func listFiles() async -> Result<[MediaLibraryAudioFile], MediaLibraryRepositoryError>
    
    func getInfo(fileId: UUID) async -> Result<MediaLibraryAudioFile, MediaLibraryRepositoryError>
    
    func getItem(id: UUID) async -> Result<MediaLibraryItem, MediaLibraryRepositoryError>
}

public protocol MediaLibraryRepository: MediaLibraryRepositoryOutput, MediaLibraryRepositoryInput {
    
}
