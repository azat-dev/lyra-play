//
//  ProvideTranslationsForSubtitlesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.07.22.
//

import Foundation

// MARK: - Interfaces

public enum ProvideTranslationsForSubtitlesUseCaseError: Error {
    
    case internalError(Error?)
}

public protocol ProvideTranslationsForSubtitlesUseCase {
    
    func prepare(for mediaId: UUID, subtitles: Subtitles) async -> Result<Void, ProvideTranslationsForSubtitlesUseCaseError>
    
    func fetchTranslations(words: [String]) async -> Result<[String: SubtitlesTranslation], ProvideTranslationsForSubtitlesUseCaseError>
}

// MARK: - Implementations

public final class DefaultProvideTranslationsForSubtitlesUseCase {
    
    private let dictionaryRepository: DictionaryRepository
    
    public init(
        dictionaryRepository: DictionaryRepository
    ) {
        
        self.dictionaryRepository = dictionaryRepository
    }
}

extension DefaultProvideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCase {
    
    public func prepare(for mediaId: UUID, subtitles: Subtitles) -> Result<Void, ProvideTranslationsForSubtitlesUseCaseError> {
        
        return .success(())
    }
    
    public func fetchTranslations(words: [String]) async -> Result<[String : SubtitlesTranslation], ProvideTranslationsForSubtitlesUseCaseError> {
        
        return .success([String: SubtitlesTranslation]())
    }
}

