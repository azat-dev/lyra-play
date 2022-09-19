//
//  ImportAudioFileUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public final class ImportAudioFileUseCaseImpl: ImportAudioFileUseCase {

    // MARK: - Properties

    private let mediaLibraryRepository: MediaLibraryRepository
    private let audioFilesRepository: FilesRepository
    private let imagesRepository: FilesRepository
    private let tagsParser: TagsParser
    private let fileNameGenerator: ImportAudioFileUseCaseFileNameGenerator

    // MARK: - Initializers

    public init(
        mediaLibraryRepository: MediaLibraryRepository,
        audioFilesRepository: FilesRepository,
        imagesRepository: FilesRepository,
        tagsParser: TagsParser,
        fileNameGenerator: ImportAudioFileUseCaseFileNameGenerator
    ) {

        self.mediaLibraryRepository = mediaLibraryRepository
        self.audioFilesRepository = audioFilesRepository
        self.imagesRepository = imagesRepository
        self.tagsParser = tagsParser
        self.fileNameGenerator = fileNameGenerator
    }
}

// MARK: - Input Methods

extension ImportAudioFileUseCaseImpl {

}

// MARK: - Output Methods

extension ImportAudioFileUseCaseImpl {

    public func importFile(originalFileName: String, fileData: Data) async -> Result<MediaLibraryAudioFile, ImportAudioFileUseCaseError> {
        
        let audioFileName = fileNameGenerator.generate(originalName: originalFileName)
        
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
        
        let audioFile = MediaLibraryAudioFile(
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
        
        let resultPutFile = await mediaLibraryRepository.putFile(info: audioFile)
        
        guard case .success(let savedFileInfo) = resultPutFile else {
            return .failure(.internalError(nil))
        }
        
        return .success(savedFileInfo)
    }
    
    public func importFile(
        targetFolderId: UUID?,
        originalFileName: String,
        fileData: Data
    ) async -> Result<MediaLibraryFile, ImportAudioFileUseCaseError> {
        
        let mediaFileName = fileNameGenerator.generate(originalName: originalFileName)
        
        let saveDataResult = await audioFilesRepository.putFile(name: mediaFileName, data: fileData)
        
        if case .failure(let error) = saveDataResult {
            return .failure(.internalError(error))
        }
        
        let fileUrl = audioFilesRepository.getFileUrl(name: mediaFileName)
        
        let parseResult = await tagsParser.parse(url: fileUrl)
        
        guard case .success(let tags) = parseResult else {
            
            let _ = await audioFilesRepository.deleteFile(name: mediaFileName)
            return .failure(.wrongFormat)
        }
        
        var savedCoverImageName: String?
        
        let title = tags.title ?? originalFileName
        
        if let coverImage = tags.coverImage {
            
            let imageName = fileNameGenerator.generate(originalName: "\(title).\(coverImage.fileExtension)")
            
            let saveImageResult = await imagesRepository.putFile(name: imageName, data: coverImage.data)
            
            if case .success = saveImageResult {
                savedCoverImageName = imageName
            }
        }
        
        let item = NewMediaLibraryFileData(
            parentId: targetFolderId,
            title: title,
            subtitle: tags.artist,
            file: mediaFileName,
            duration: tags.duration,
            image: savedCoverImageName,
            genre: tags.genre
        )
        
        let resulSaveFile = await mediaLibraryRepository.createFile(data: item)
        
        guard case .success(let savedFileInfo) = resulSaveFile else {
            return .failure(.internalError(nil))
        }
        
        return .success(savedFileInfo)
    }
}
