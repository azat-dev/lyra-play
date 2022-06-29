//
//  AudioFilesRepositoryMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import LyraPlay

class AudioFilesRepositoryMock: AudioLibraryRepository {
    
    private var files = [AudioFileInfo]()
    
    func listFiles() async -> Result<[AudioFileInfo], AudioFilesRepositoryError> {
        
        return .success(files)
    }
    
    func getInfo(fileId: UUID) async -> Result<AudioFileInfo, AudioFilesRepositoryError> {
        
        guard let info = files.first(where: { $0.id == fileId }) else {
            return .failure(.fileNotFound)
        }
        
        return .success(info)
    }
    
    func putFile(info fileInfo: AudioFileInfo, data: Data) async -> Result<AudioFileInfo, AudioFilesRepositoryError> {
        
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
    
    func delete(fileId: UUID) async -> Result<Void, AudioFilesRepositoryError> {
        self.files = files.filter { $0.id != fileId }
        
        return .success(())
    }
}
