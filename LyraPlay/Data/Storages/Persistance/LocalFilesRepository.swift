//
//  LocalFilesRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.06.22.
//

import Foundation

public final class LocalFilesRepository: FilesRepository {

    private var baseDirectory: URL
    
    public init(baseDirectory: URL) throws {
        
        self.baseDirectory = baseDirectory
        
        do {
            try FileManager.default.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
        } catch {
            throw FilesRepositoryError.internalError(error)
        }
    }
    
    public func getFileUrl(name: String) -> URL {
        return baseDirectory.appendingPathComponent(name, isDirectory: false)
    }
    
    public func putFile(name: String, data: Data) async -> Result<Void, FilesRepositoryError> {
        
        let url = baseDirectory.appendingPathComponent(name, isDirectory: false)
        
        try! data.write(to: url)
        
        return .success(())
    }
    
    public func getFile(name: String) async -> Result<Data, FilesRepositoryError> {
        
        let url = getFileUrl(name: name)

        guard FileManager.default.fileExists(atPath: url.path) else {
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
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            return .failure(.fileNotFound)
        }
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            return .failure(.internalError(error))
        }
        
        return .success(())
    }
}
