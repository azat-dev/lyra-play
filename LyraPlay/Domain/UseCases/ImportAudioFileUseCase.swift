//
//  ImportAudioFileUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 24.06.22.
//

import Foundation

// MARK: - Interfaces

public enum ImportAudioFileUseCaseError: Error {
    case wrongFormat
    case internalError(Error?)
}

public protocol ImportAudioFileUseCase {
    
    func importFile(originalFileName: String, fileData: Data) async -> Result<AudioFileInfo, ImportAudioFileUseCaseError>
}

// MARK: - Implementations

public final class DefaultImportAudioFileUseCase: ImportAudioFileUseCase {
    
    private var audioLibraryRepository: AudioLibraryRepository
    private var imagesRepository: FilesRepository
    private var audioFilesRepository: FilesRepository
    private var tagsParser: TagsParser
    
    public init(
        audioLibraryRepository: AudioLibraryRepository,
        audioFilesRepository: FilesRepository,
        imagesRepository: FilesRepository,
        tagsParser: TagsParser
    ) {
        
        self.audioLibraryRepository = audioLibraryRepository
        self.imagesRepository = imagesRepository
        self.tagsParser = tagsParser
        self.audioFilesRepository = audioFilesRepository
    }
    
    private func generateAudioFileName(originalName: String) -> String {
        
        let audioFileId = UUID().uuidString
        let fileExtension = URL(fileURLWithPath: originalName).pathExtension
        return "\(audioFileId).\(fileExtension)"
    }
    
    public func importFile(originalFileName: String, fileData: Data) async -> Result<AudioFileInfo, ImportAudioFileUseCaseError> {
        
        let audioFileName = generateAudioFileName(originalName: originalFileName)
        
        let saveDataResult = await audioFilesRepository.putFile(name: audioFileName, data: fileData)
        if case .failure(let error) = saveDataResult {
            return .failure(.internalError(error))
        }
        
        let fileUrl = audioFilesRepository.getFileUrl(name: audioFileName)
        
        let parseResult = await tagsParser.parse(url: fileUrl)
        
        guard case .success(let tags) = parseResult else {
            return .failure(.wrongFormat)
        }
        
        var savedCoverImageName: String?
        
        if let coverImage = tags.coverImage {
            
            let imageId = UUID().uuidString
            let imageName = "\(imageId).\(coverImage.fileExtension)"
            
            let saveImageResult = await imagesRepository.putFile(name: imageName, data: coverImage.data)
            if case .success = saveImageResult {
                savedCoverImageName = imageName
            }
        }
        
        let audioFile = AudioFileInfo(
            id: nil,
            createdAt: .now,
            updatedAt: nil,
            name: tags.title ?? originalFileName,
            duration: tags.duration,
            audioFile: audioFileName,
            artist: tags.artist,
            genre: tags.genre,
            coverImage: savedCoverImageName
        )
        
        let resultPutFile = await audioLibraryRepository.putFile(info: audioFile, data: fileData)
        
        guard case .success(let savedFileInfo) = resultPutFile else {
            return .failure(.internalError(nil))
        }
        
        return .success(savedFileInfo)
    }
}
