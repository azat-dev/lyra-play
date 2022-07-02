//
//  AudioLibraryRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 24.06.22.
//

import Foundation

// MARK: - Interfaces

public enum AudioLibraryRepositoryError: Error {
    
    case fileNotFound
    case internalError(Error? = nil)
}

public protocol AudioLibraryRepository {
    
    func listFiles() async -> Result<[AudioFileInfo], AudioLibraryRepositoryError>
    func getInfo(fileId: UUID) async -> Result<AudioFileInfo, AudioLibraryRepositoryError>
    func putFile(info: AudioFileInfo, data: Data) async -> Result<AudioFileInfo, AudioLibraryRepositoryError>
    func delete(fileId: UUID) async -> Result<Void, AudioLibraryRepositoryError>
}
