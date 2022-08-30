//
//  ImportSubtitlesUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public final class ImportSubtitlesUseCaseImpl: ImportSubtitlesUseCase {
    
    // MARK: - Properties
    
    private let supportedExtensions: [String]
    private let subtitlesRepository: SubtitlesRepository
    private let subtitlesParser: SubtitlesParser
    private let subtitlesFilesRepository: FilesRepository
    
    // MARK: - Initializers
    
    public init(
        supportedExtensions: [String],
        subtitlesRepository: SubtitlesRepository,
        subtitlesParser: SubtitlesParser,
        subtitlesFilesRepository: FilesRepository
    ) {
        
        self.supportedExtensions = supportedExtensions
        self.subtitlesRepository = subtitlesRepository
        self.subtitlesParser = subtitlesParser
        self.subtitlesFilesRepository = subtitlesFilesRepository
    }
}

// MARK: - Input Methods

extension ImportSubtitlesUseCaseImpl {
}

// MARK: - Output Methods

extension ImportSubtitlesUseCaseImpl {
    
    public func importFile(
        trackId: UUID,
        language: String,
        fileName: String,
        data: Data
    ) async -> Result<Void, ImportSubtitlesUseCaseError> {
        
        let fileExtension = "." + URL(fileURLWithPath: fileName).pathExtension.lowercased()
        
        guard supportedExtensions.contains(fileExtension) else {
            return .failure(.formatNotSupported)
        }
        
        guard let text = String(data: data, encoding: .utf8) else {
            return .failure(.wrongData)
        }
        
        let parseResult = await subtitlesParser.parse(text, fileName: fileName)
        
        guard case .success = parseResult else {
            return .failure(.wrongData)
        }
        
        let fileName = "\(trackId)/\(language)\(fileExtension)"
        
        let resultSaveFile = await subtitlesFilesRepository.putFile(
            name: fileName,
            data: data
        )
        
        guard case .success = resultSaveFile else {
            return .failure(.internalError(resultSaveFile.error))
        }
        
        let record = SubtitlesInfo(
            mediaFileId: trackId,
            language: language,
            file: fileName
        )
        
        let resultPutRecord = await subtitlesRepository.put(info: record)
        
        guard case .success = resultPutRecord else {
            return .failure(.internalError(resultPutRecord.error))
        }
        
        return .success(())
    }
}
