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

public final class DefaultLoadSubtitlesUseCase: LoadSubtitlesUseCase {

    
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
    
    private static func map(_ error: SubtitlesRepositoryError) -> LoadSubtitlesUseCaseError {
        
        switch error {
        case .itemNotFound:
            return .itemNotFound
            
        case .internalError(let err):
            return .internalError(err)
        }
    }
    
    private static func map(_ error: FilesRepositoryError) -> LoadSubtitlesUseCaseError {

        switch error {
        case .fileNotFound:
            return .itemNotFound
            
        case .internalError(let err):
            return .internalError(err)
        }
    }
    
    private static func map(_ error: SubtitlesParserError) -> LoadSubtitlesUseCaseError {

        switch error {
        case .internalError(let err):
            return .internalError(err)
        }
    }
    
    public func load(for mediaFileId: UUID, language: String) async -> Result<Subtitles, LoadSubtitlesUseCaseError> {
        
        let resultInfo = await subtitlesRepository.fetch(
            mediaFileId: mediaFileId,
            language: language
        )
        
        guard case .success(let subtitlesInfo) = resultInfo else {

            let mappedError = Self.map(resultInfo.error!)
            return .failure(mappedError)
        }
        
        let fileName = subtitlesInfo.file
        
        let fileResult = await subtitlesFiles.getFile(name: fileName)
        
        guard case .success(let fileData) = fileResult else {
            
            let mappedError = Self.map(fileResult.error!)
            return .failure(mappedError)
        }
        
        guard let text = String(data: fileData, encoding: .utf8) else {
            return .failure(.internalError(nil))
        }
        
        let parseResult = await subtitlesParser.parse(text)

        guard case .success(let subtitles) = parseResult else {

            let mappedError = Self.map(parseResult.error!)
            return .failure(mappedError)
        }
        
        return .success(subtitles)
    }
}

