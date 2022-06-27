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
    
    private var audioFilesRepository: AudioFilesRepository
    private var tagsParser: TagsParser
    
    public init(audioFilesRepository: AudioFilesRepository, tagsParser: TagsParser) {
        
        self.audioFilesRepository = audioFilesRepository
        self.tagsParser = tagsParser
    }
    
    public func importFile(originalFileName: String, fileData: Data) async -> Result<AudioFileInfo, ImportAudioFileUseCaseError> {
        
        let parseResult = await tagsParser.parse(data: fileData)
        
        guard case .success(let tags) = parseResult else {
            return .failure(.wrongFormat)
        }
        
        let audioFile = AudioFileInfo(
            id: nil,
            createdAt: .now,
            updatedAt: nil,
            name: tags?.title ?? originalFileName,
            artist: tags?.artist,
            genre: tags?.genre
        )
        
        let resultPutFile = await audioFilesRepository.putFile(info: audioFile, data: fileData)
        
        guard case .success(let savedFileInfo) = resultPutFile else {
            return .failure(.internalError(nil))
        }
        
        return .success(savedFileInfo)
    }
}
