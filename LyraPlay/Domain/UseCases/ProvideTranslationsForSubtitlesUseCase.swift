//
//  ProvideTranslationsForSubtitlesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.08.2022.
//

import Foundation

// MARK: - Interfaces

public struct ProvideTranslationsForSubtitlesUseCaseOptions: Equatable {

    public var mediaId: UUID?
    public var nativeLanguage: String
    public var learningLanguage: String
    public var subtitles: Subtitles

    public init(
        mediaId: UUID?,
        nativeLanguage: String,
        learningLanguage: String,
        subtitles: Subtitles
    ) {

        self.mediaId = mediaId
        self.nativeLanguage = nativeLanguage
        self.learningLanguage = learningLanguage
        self.subtitles = subtitles
    }
}

public struct SubtitlesTranslationItem: Equatable {

    public var dictionaryItemId: UUID
    public var translationId: UUID
    public var originalText: String
    public var translatedText: String

    public init(
        dictionaryItemId: UUID,
        translationId: UUID,
        originalText: String,
        translatedText: String
    ) {

        self.dictionaryItemId = dictionaryItemId
        self.translationId = translationId
        self.originalText = originalText
        self.translatedText = translatedText
    }
}

public struct SubtitlesTranslation: Equatable {

    public var textRange: Range<String.Index>
    public var translation: SubtitlesTranslationItem

    public init(
        textRange: Range<String.Index>,
        translation: SubtitlesTranslationItem
    ) {

        self.textRange = textRange
        self.translation = translation
    }
}

public protocol ProvideTranslationsForSubtitlesUseCaseInput {

    func prepare(options: ProvideTranslationsForSubtitlesUseCaseOptions) async -> Void
}

public protocol ProvideTranslationsForSubtitlesUseCaseOutput {

    func getTranslations(sentenceIndex: Int) async -> [SubtitlesTranslation]
}

public protocol ProvideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCaseOutput, ProvideTranslationsForSubtitlesUseCaseInput {
}

// MARK: - Implementations

public final class DefaultProvideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCase {

    // MARK: - Properties

    private let dictionaryRepository: DictionaryRepository
    private let textSplitter: TextSplitter
    private let lemmatizer: Lemmatizer

    // MARK: - Initializers

    public init(
        dictionaryRepository: DictionaryRepository,
        textSplitter: TextSplitter,
        lemmatizer: Lemmatizer
    ) {

        self.dictionaryRepository = dictionaryRepository
        self.textSplitter = textSplitter
        self.lemmatizer = lemmatizer
    }
}

// MARK: - Input methods

extension DefaultProvideTranslationsForSubtitlesUseCase {

    public func prepare(options: ProvideTranslationsForSubtitlesUseCaseOptions) async -> Void {

        fatalError("Not implemented")
    }
}
// MARK: - Output methods

extension DefaultProvideTranslationsForSubtitlesUseCase {

    public func getTranslations(sentenceIndex: Int) async -> [SubtitlesTranslation] {

        fatalError("Not implemented")
    }
}
