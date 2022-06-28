//
//  BrowseAudioFilesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation

// MARK: - Interfaces

public enum BrowseAudioFilesUseCaseError: Error {
    
    case fileNotFound
    case internalError
}

public protocol BrowseAudioFilesUseCase {
    
    func listFiles() async -> Result<[AudioFileInfo], BrowseAudioFilesUseCaseError>
    
    func getFileInfo(fileId: UUID) async -> Result<AudioFileInfo, BrowseAudioFilesUseCaseError>
}

// MARK: - Implementations

public final class DefaultBrowseAudioFilesUseCase: BrowseAudioFilesUseCase {
    
    private let audioFilesRepository: AudioFilesRepository
    
    public init(audioFilesRepository: AudioFilesRepository) {
        
        self.audioFilesRepository = audioFilesRepository
    }
    
    private func addTestFiles() async {
        
        let filesResult = await audioFilesRepository.listFiles()
        
        guard case .success(let files) = filesResult else {
            return
        }
        
        guard files.count == 0 else {
            return
        }
        
        let numberOfFiles = 10
        
        for index in 0..<numberOfFiles {
            await audioFilesRepository.putFile(info: AudioFileInfo.create(name: "test\(index)"), data: "test\(index)".data(using: .utf8)!)
        }
    }
    
    private func mapRepositoryError(_ error: AudioFilesRepositoryError) -> BrowseAudioFilesUseCaseError {
        
        switch error {
        case .fileNotFound:
            return .fileNotFound
        case .internalError:
            return .internalError
        }
    }
    
    public func listFiles() async -> Result<[AudioFileInfo], BrowseAudioFilesUseCaseError> {
        
        await addTestFiles()
        
        let result = await audioFilesRepository.listFiles()

        switch result {
        case .success(let files):
            return .success(files)
            
        case .failure(let error):
            return .failure(mapRepositoryError(error))
        }
    }
    
    public func getFileInfo(fileId: UUID) async -> Result<AudioFileInfo, BrowseAudioFilesUseCaseError> {
        
        let result = await audioFilesRepository.getInfo(fileId: fileId)

        switch result {
        case .success(let file):
            return .success(file)
            
        case .failure(let error):
            return .failure(mapRepositoryError(error))
        }
    }
}
