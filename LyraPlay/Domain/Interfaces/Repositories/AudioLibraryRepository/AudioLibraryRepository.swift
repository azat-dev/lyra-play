//
//  AudioLibraryRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public enum AudioLibraryRepositoryError: Error {
    
    case fileNotFound
    case internalError(Error?)
}

public protocol AudioLibraryRepositoryInput {
    
    func putFile(info: AudioFileInfo) async -> Result<AudioFileInfo, AudioLibraryRepositoryError>
    
    func delete(fileId: UUID) async -> Result<Void, AudioLibraryRepositoryError>
}

public protocol AudioLibraryRepositoryOutput {
    
    func listFiles() async -> Result<[AudioFileInfo], AudioLibraryRepositoryError>
    
    func getInfo(fileId: UUID) async -> Result<AudioFileInfo, AudioLibraryRepositoryError>
}

public protocol AudioLibraryRepository: AudioLibraryRepositoryOutput, AudioLibraryRepositoryInput {
    
}
