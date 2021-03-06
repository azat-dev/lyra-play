//
//  AudioFilesRepositoryMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import LyraPlay

class AudioLibraryRepositoryMock: AudioLibraryRepository {
    
    private var files = [AudioFileInfo]()
    
    func listFiles() async -> Result<[AudioFileInfo], AudioLibraryRepositoryError> {
        
        return .success(files)
    }
    
    func getInfo(fileId: UUID) async -> Result<AudioFileInfo, AudioLibraryRepositoryError> {
        
        guard let info = files.first(where: { $0.id == fileId }) else {
            return .failure(.fileNotFound)
        }
        
        return .success(info)
    }
    
    func putNewFileWithId(info fileInfo: AudioFileInfo) async -> Result<AudioFileInfo, AudioLibraryRepositoryError> {
        
        let fileId = fileInfo.id!
        
        guard let existingIndex = files.firstIndex(where: { $0.id == fileId }) else {
            files.append(fileInfo)
            return .success(fileInfo)
        }
        
        files[existingIndex] = fileInfo
        
        return .success(fileInfo)
    }
    
    func putFile(info fileInfo: AudioFileInfo) async -> Result<AudioFileInfo, AudioLibraryRepositoryError> {
        
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
    
    func delete(fileId: UUID) async -> Result<Void, AudioLibraryRepositoryError> {
        self.files = files.filter { $0.id != fileId }
        
        return .success(())
    }
}
