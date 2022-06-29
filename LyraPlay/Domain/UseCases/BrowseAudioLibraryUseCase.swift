//
//  BrowseAudioLibraryUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation

// MARK: - Interfaces

public enum BrowseAudioLibraryUseCaseError: Error {
    
    case fileNotFound
    case internalError
}

public protocol BrowseAudioLibraryUseCase {
    
    func listFiles() async -> Result<[AudioFileInfo], BrowseAudioLibraryUseCaseError>
    
    func getFileInfo(fileId: UUID) async -> Result<AudioFileInfo, BrowseAudioLibraryUseCaseError>
    
    func fetchImage(name: String) async -> Result<Data, BrowseAudioLibraryUseCaseError>
}

// MARK: - Implementations

public final class DefaultBrowseAudioLibraryUseCase: BrowseAudioLibraryUseCase {
    
    private let audioLibraryRepository: AudioLibraryRepository
    private let imagesRepository: FilesRepository

    
    public init(audioLibraryRepository: AudioLibraryRepository, imagesRepository: FilesRepository) {
        
        self.audioLibraryRepository = audioLibraryRepository
        self.imagesRepository = imagesRepository
    }
    
//    private func addTestFiles() async {
//
//        let filesResult = await audioLibraryRepository.listFiles()
//
//        guard case .success(let files) = filesResult else {
//            return
//        }
//
//        guard files.count == 0 else {
//            return
//        }
//
//        let numberOfFiles = 10
//
//        for index in 0..<numberOfFiles {
//            await audioLibraryRepository.putFile(info: AudioFileInfo.create(name: "test\(index)"), data: "test\(index)".data(using: .utf8)!)
//        }
//    }
    
    private func mapRepositoryError(_ error: AudioFilesRepositoryError) -> BrowseAudioLibraryUseCaseError {
        
        switch error {
        case .fileNotFound:
            return .fileNotFound
        case .internalError:
            return .internalError
        }
    }
    
    public func listFiles() async -> Result<[AudioFileInfo], BrowseAudioLibraryUseCaseError> {
        
//        await addTestFiles()
        
        let result = await audioLibraryRepository.listFiles()

        switch result {
        case .success(let files):
            return .success(files)
            
        case .failure(let error):
            return .failure(mapRepositoryError(error))
        }
    }
    
    public func getFileInfo(fileId: UUID) async -> Result<AudioFileInfo, BrowseAudioLibraryUseCaseError> {
        
        let result = await audioLibraryRepository.getInfo(fileId: fileId)

        switch result {
        case .success(let file):
            return .success(file)
            
        case .failure(let error):
            return .failure(mapRepositoryError(error))
        }
    }
    
    public func fetchImage(name: String) async -> Result<Data, BrowseAudioLibraryUseCaseError> {
        
        let result = await imagesRepository.getFile(name: name)
        
        switch result {

        case .failure(let error):
            guard case .fileNotFound = error else {
                return .failure(.internalError)
            }
            
            return .failure(.fileNotFound)
            
        case .success(let imageData):
            return .success(imageData)
        }
    }
}
