//
//  AudioFilesRepositoryMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import LyraPlay

class MediaLibraryRepositoryMockDeprecated: MediaLibraryRepository {
    
    public var files = [MediaLibraryItem]()
    
    func listFiles() async -> Result<[MediaLibraryItem], MediaLibraryRepositoryError> {
        
        return .success(files)
    }
    
    func getInfo(fileId: UUID) async -> Result<MediaLibraryItem, MediaLibraryRepositoryError> {
        
        guard let info = files.first(where: { $0.id == fileId }) else {
            return .failure(.fileNotFound)
        }
        
        return .success(info)
    }
    
    func putNewFileWithId(info fileInfo: MediaLibraryItem) async -> Result<MediaLibraryItem, MediaLibraryRepositoryError> {
        
        let fileId = fileInfo.id!
        
        guard let existingIndex = files.firstIndex(where: { $0.id == fileId }) else {
            files.append(fileInfo)
            return .success(fileInfo)
        }
        
        files[existingIndex] = fileInfo
        
        return .success(fileInfo)
    }
    
    func putFile(info fileInfo: MediaLibraryItem) async -> Result<MediaLibraryItem, MediaLibraryRepositoryError> {
        
        guard let fileId = fileInfo.id else {
            
            var newFileInfo = fileInfo
            newFileInfo.id = UUID()
            files.append(newFileInfo)
            
            return .success(newFileInfo)
        }
        
        guard let existingIndex = files.firstIndex(where: { $0.id == fileId }) else {
            return .failure(.fileNotFound)
        }
        
        files[existingIndex] = fileInfo
        
        return .success(fileInfo)
    }
    
    func delete(fileId: UUID) async -> Result<Void, MediaLibraryRepositoryError> {
        self.files = files.filter { $0.id != fileId }
        
        return .success(())
    }
}
