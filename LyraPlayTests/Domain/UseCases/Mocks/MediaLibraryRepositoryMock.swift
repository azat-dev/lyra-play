//
//  AudioFilesRepositoryMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import LyraPlay

class MediaLibraryRepositoryMockDeprecated: MediaLibraryRepository {
    
    func listItems(folderId: UUID?) async -> Result<[MediaLibraryItem], MediaLibraryRepositoryError> {
        fatalError()
    }
    
    
    func createFolder(data: NewMediaLibraryFolderData) async -> Result<MediaLibraryFolder, MediaLibraryRepositoryError> {
        fatalError()
    }
    
    
    func createFile(data: NewMediaLibraryFileData) async -> Result<MediaLibraryFile, MediaLibraryRepositoryError> {
        fatalError()
    }
    
    func deleteFile(id: UUID) async -> Result<Void, MediaLibraryRepositoryError> {
        fatalError()
    }
    
    
    public var files = [MediaLibraryAudioFile]()
    
    func listFiles() async -> Result<[MediaLibraryAudioFile], MediaLibraryRepositoryError> {
        
        return .success(files)
    }
    
    func getInfo(fileId: UUID) async -> Result<MediaLibraryAudioFile, MediaLibraryRepositoryError> {
        
        guard let info = files.first(where: { $0.id == fileId }) else {
            return .failure(.fileNotFound)
        }
        
        return .success(info)
    }
    
    func getItem(id: UUID) async -> Result<MediaLibraryItem, MediaLibraryRepositoryError> {
        
        fatalError()
    }
    
    func putNewFileWithId(info fileInfo: MediaLibraryAudioFile) async -> Result<MediaLibraryAudioFile, MediaLibraryRepositoryError> {
        
        let fileId = fileInfo.id!
        
        guard let existingIndex = files.firstIndex(where: { $0.id == fileId }) else {
            files.append(fileInfo)
            return .success(fileInfo)
        }
        
        files[existingIndex] = fileInfo
        
        return .success(fileInfo)
    }
    
    func putFile(info fileInfo: MediaLibraryAudioFile) async -> Result<MediaLibraryAudioFile, MediaLibraryRepositoryError> {
        
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
