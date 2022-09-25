//
//  FilesRepositoryMockDeprecated.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 28.06.22.
//

import Foundation
import LyraPlay

class FilesRepositoryMockDeprecated: FilesRepository {
    
    public var files = [String: Data]()
    
    func putFile(name: String, data: Data) async -> Result<Void, FilesRepositoryError> {

        files[name] = data
        return .success(())
    }
    
    func getFileUrl(name: String) -> URL {
        return URL(string: name)!
    }
    
    func getFile(name: String) async -> Result<Data, FilesRepositoryError> {
        
        guard let file = files[name] else {
            return .failure(.fileNotFound)
        }
        
        return .success(file)
    }
    
    func deleteFile(name: String) async -> Result<Void, FilesRepositoryError> {
        
        files.removeValue(forKey: name)
        return .success(())
    }
}
