//
//  ImportSubtitlesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.07.22.
//

import Foundation

// MARK: - Interfaces

public enum ImportSubtitlesUseCaseError: Error {
    
    case internalError(Error?)
    case wrongData
    case formatNotSupported
}

public protocol ImportSubtitlesUseCase {
    
    func importFile(trackId: UUID, language: String, fileName: String, data: Data) async -> Result<Void, ImportSubtitlesUseCaseError>
}

// MARK: - Implementations

public final class DefaultImportSubtitlesUseCase: ImportSubtitlesUseCase {
    
    private let subtitlesRepository: SubtitlesRepository
    private let subtitlesFilesRepository: FilesRepository
    private let subtitlesParser: SubtitlesParser
    
    public init(
        subtitlesRepository: SubtitlesRepository,
        subtitlesParser: SubtitlesParser,
        subtitlesFilesRepository: FilesRepository
    ) {
        
        self.subtitlesRepository = subtitlesRepository
        self.subtitlesParser = subtitlesParser
        self.subtitlesFilesRepository = subtitlesFilesRepository
    }
    
    public func importFile(trackId: UUID, language: String, fileName: String, data: Data) async -> Result<Void, ImportSubtitlesUseCaseError> {
        
        guard !fileName.hasPrefix(".lrc") else {
            return .failure(.formatNotSupported)
        }
        
        guard let text = String(data: data, encoding: .utf8) else {
            return .failure(.wrongData)
        }
        
        let parseResult = await subtitlesParser.parse(text)
        
        guard case .success = parseResult else {
            return .failure(.wrongData)
        }
        
        let fileName = "\(trackId)/\(language).lrc"
        
        print(fileName)
        
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

