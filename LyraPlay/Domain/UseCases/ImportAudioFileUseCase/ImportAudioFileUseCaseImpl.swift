//
//  ImportAudioFileUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

import Foundation

public final class ImportAudioFileUseCaseImpl: ImportAudioFileUseCase {

    // MARK: - Properties

    private let audioLibraryRepository: AudioLibraryRepository
    private let audioFilesRepository: FilesRepository
    private let imagesRepository: FilesRepository
    private let tagsParser: TagsParser

    // MARK: - Initializers

    public init(
        audioLibraryRepository: AudioLibraryRepository,
        audioFilesRepository: FilesRepository,
        imagesRepository: FilesRepository,
        tagsParser: TagsParser
    ) {

        self.audioLibraryRepository = audioLibraryRepository
        self.audioFilesRepository = audioFilesRepository
        self.imagesRepository = imagesRepository
        self.tagsParser = tagsParser
    }
}

// MARK: - Input Methods

extension ImportAudioFileUseCaseImpl {

}

// MARK: - Output Methods

extension ImportAudioFileUseCaseImpl {

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
        
        let resultPutFile = await audioLibraryRepository.putFile(info: audioFile)
        
        guard case .success(let savedFileInfo) = resultPutFile else {
            return .failure(.internalError(nil))
        }
        
        return .success(savedFileInfo)
    }
}
