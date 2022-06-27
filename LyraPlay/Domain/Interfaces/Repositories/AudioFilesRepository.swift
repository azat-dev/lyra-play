//
//  AudioFilesRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 24.06.22.
//

import Foundation

// MARK: - Interfaces

public enum AudioFilesRepositoryError: Error {
    case fileNotFound
    case internalError
}

public protocol AudioFilesRepository {
    
    func listFiles() async -> Result<[AudioFileInfo], AudioFilesRepositoryError>
    func getInfo(fileId: UUID) async -> Result<AudioFileInfo, AudioFilesRepositoryError>
    func putFile(info: AudioFileInfo, data: Data) async -> Result<AudioFileInfo, AudioFilesRepositoryError>
    func delete(fileId: UUID) async -> Result<Void, AudioFilesRepositoryError>
}
