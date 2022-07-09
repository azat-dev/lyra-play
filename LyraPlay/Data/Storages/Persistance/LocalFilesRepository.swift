//
//  LocalFilesRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.06.22.
//

import Foundation

public final class LocalFilesRepository: FilesRepository {

    private var baseDirectory: URL
    private let fileManager: FileManager
    
    public init(baseDirectory: URL, fileManager: FileManager = FileManager.default) throws {
        
        self.baseDirectory = baseDirectory
        self.fileManager = fileManager
        
        do {
            try fileManager.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
        } catch {
            throw FilesRepositoryError.internalError(error)
        }
    }
    
    public func getFileUrl(name: String) -> URL {
        return baseDirectory.appendingPathComponent(name, isDirectory: false)
    }
    
    public func putFile(name: String, data: Data) async -> Result<Void, FilesRepositoryError> {
        
        let url = baseDirectory.appendingPathComponent(name, isDirectory: false)
        let tempUrl = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: false)
        
        fileManager.createFile(atPath: tempUrl.path, contents: data, attributes: nil)
        
        do {
            
            let _ = try fileManager.replaceItemAt(url, withItemAt: tempUrl)
        } catch {
            return .failure(.internalError(error))
        }
        
        
        try? fileManager.removeItem(at: tempUrl)
        
        return .success(())
    }
    
    public func getFile(name: String) async -> Result<Data, FilesRepositoryError> {
        
        let url = getFileUrl(name: name)

        guard fileManager.fileExists(atPath: url.path) else {
            return .failure(.fileNotFound)
        }
        
        do {
            let data = try Data(contentsOf: url)
            return .success(data)
            
        } catch {
            return .failure(.internalError(error))
        }
    }
    
    public func deleteFile(name: String) async -> Result<Void, FilesRepositoryError> {
        
        let url = getFileUrl(name: name)
        
        guard fileManager.fileExists(atPath: url.path) else {
            return .failure(.fileNotFound)
        }
        
        do {
            try fileManager.removeItem(at: url)
        } catch {
            return .failure(.internalError(error))
        }
        
        return .success(())
    }
}
