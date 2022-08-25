//
//  LoadSubtitlesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.07.22.
//

import Foundation

// MARK: - Interfaces

public enum LoadSubtitlesUseCaseError: Error {
    
    case itemNotFound
    case internalError(Error?)
}

public protocol LoadSubtitlesUseCase {
    
    func load(for: UUID, language: String) async -> Result<Subtitles, LoadSubtitlesUseCaseError>
}

// MARK: - Implementations

public final class LoadSubtitlesUseCaseImpl: LoadSubtitlesUseCase {
    
    
    private let subtitlesRepository: SubtitlesRepository
    private let subtitlesFiles: FilesRepository
    private let subtitlesParser: SubtitlesParser
    
    public init(
        subtitlesRepository: SubtitlesRepository,
        subtitlesFiles: FilesRepository,
        subtitlesParser: SubtitlesParser
    ) {
        
        self.subtitlesRepository = subtitlesRepository
        self.subtitlesFiles = subtitlesFiles
        self.subtitlesParser = subtitlesParser
    }
    
    public func load(for mediaFileId: UUID, language: String) async -> Result<Subtitles, LoadSubtitlesUseCaseError> {
        
        let resultInfo = await subtitlesRepository.fetch(
            mediaFileId: mediaFileId,
            language: language
        )
        
        guard case .success(let subtitlesInfo) = resultInfo else {
            
            return .failure(resultInfo.error!.map())
        }
        
        let fileName = subtitlesInfo.file
        
        let fileResult = await subtitlesFiles.getFile(name: fileName)
        
        guard case .success(let fileData) = fileResult else {
            
            return .failure(fileResult.error!.map())
        }
        
        guard let text = String(data: fileData, encoding: .utf8) else {
            return .failure(.internalError(nil))
        }
        
        let parseResult = await subtitlesParser.parse(text, fileName: fileName)
        
        guard case .success(let subtitles) = parseResult else {
            
            return .failure(parseResult.error!.map())
        }
        
        return .success(subtitles)
    }
}

// MARK: - Map Errors

fileprivate extension SubtitlesRepositoryError {
    
    func map() -> LoadSubtitlesUseCaseError {
        
        switch self {
            
        case .itemNotFound:
            return .itemNotFound
            
        case .internalError(let err):
            return .internalError(err)
        }
    }
}

fileprivate extension FilesRepositoryError {
    
    func map() -> LoadSubtitlesUseCaseError {
        
        switch self {
        case .fileNotFound:
            return .itemNotFound
            
        case .internalError(let err):
            return .internalError(err)
        }
    }
}

fileprivate extension SubtitlesParserError {
    
    func map() -> LoadSubtitlesUseCaseError {
        
        switch self {
        case .internalError(let err):
            return .internalError(err)
        }
    }
}
