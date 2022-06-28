//
//  FilesRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.06.22.
//

import Foundation

// MARK: - Interfaces

public enum FilesRepositoryError: Error {
    
    case internalError
    case fileNotFound
}

public protocol FilesRepository {
    
    func putFile(name: String, data: Data) async -> Result<URL, FilesRepositoryError>
    
    func getFile(name: String) async -> Result<Data, FilesRepositoryError>
    
    func deleteFile(name: String) async -> Result<Void, FilesRepositoryError>
}
