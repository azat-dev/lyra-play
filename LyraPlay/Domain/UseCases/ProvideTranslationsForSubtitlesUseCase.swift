//
//  ProvideTranslationsForSubtitlesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.08.2022.
//

import Foundation

// MARK: - Interfaces

public struct ProvideTranslationsForSubtitlesUseCaseOptions: Equatable {
    
    public var mediaId: UUID
    public var nativeLanguage: String
    public var learningLanguage: String
    public var subtitles: Subtitles
    
    public init(
        mediaId: UUID,
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
    
    private typealias SentenceIndex = Int
    
    private let dictionaryRepository: DictionaryRepository
    private let textSplitter: TextSplitter
    private let lemmatizer: Lemmatizer
    
    private var items = [SentenceIndex: [SubtitlesTranslation]]()
    
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
    
    private func lemmatizeSubtitles(_ subtitles: Subtitles) -> [[LemmaItem]] {
        
        return subtitles.sentences.map { sentence in
            lemmatizer.lemmatize(text: sentence.text).map {
                return .init(lemma: $0.lemma.lowercased(), range: $0.range)
            }
        }
    }
    
    private func populateItems(sentencesWithLemmas: [[LemmaItem]], dictionaryItems: [DictionaryItem]) {
        
        let numberOfSentences = sentencesWithLemmas.count
        
        for sentenceIndex in 0..<numberOfSentences {
            
            let sentence = sentencesWithLemmas[sentenceIndex]
            
            for lemmaItem in sentence {
                
                let dictionaryItem = dictionaryItems.first { $0.lemma == lemmaItem.lemma }
                
                guard
                    let dictionaryItem = dictionaryItem,
                    let translation = dictionaryItem.translations.first
                else {
                    continue
                }
                
                var newItems = items[sentenceIndex, default: []]
                newItems.append(
                    .init(
                        textRange: lemmaItem.range,
                        translation: .init(
                            dictionaryItemId: dictionaryItem.id!,
                            translationId: translation.id!,
                            originalText: dictionaryItem.originalText,
                            translatedText: translation.text
                        )
                    )
                )
                
                items[sentenceIndex] = newItems
            }
        }
    }
    
    private func populateItems(mediaId: UUID, dictionaryItems: [DictionaryItem]) {
        
        for dictionaryItem in dictionaryItems {
            
            for translation in dictionaryItem.translations {
                
                guard translation.mediaId != mediaId else {
                    continue
                }
            }
        }
    }
    
    public func prepare(options: ProvideTranslationsForSubtitlesUseCaseOptions) async -> Void {
        
        let sentencesWithLemmas = lemmatizeSubtitles(options.subtitles)
        var uniqueLemmas = Set<String>()
        
        sentencesWithLemmas.forEach { sentence in
            sentence.forEach { lemmaItem in
                uniqueLemmas.insert(lemmaItem.lemma.lowercased())
            }
        }
        
        var searchFilters = [DictionaryItemFilter]()
        
        for lemma in uniqueLemmas {
            searchFilters.append(.init(lemma: lemma))
        }
        
        let searchResult = await dictionaryRepository.searchItems(with: searchFilters)
        
        guard case .success(let dictionaryItems) = searchResult else {
            return
        }
        
        populateItems(sentencesWithLemmas: sentencesWithLemmas, dictionaryItems: dictionaryItems)
    }
}
// MARK: - Output methods

extension DefaultProvideTranslationsForSubtitlesUseCase {
    
    public func getTranslations(sentenceIndex: Int) async -> [SubtitlesTranslation] {
        
        return items[sentenceIndex] ?? []
    }
}
