//
//  ProvideTranslationsForSubtitlesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.08.2022.
//

import Foundation

// MARK: - Interfaces

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
    
    public var originalTextLanguage: String {
        "en_US"
    }
    
    public var translatedTextLanguage: String {
        "ru_RU"
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
    
    func prepare(options: AdvancedPlayerSession) async -> Void
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
    
    private func populateItemsWithGlobalTranslations(sentencesWithLemmas: [[LemmaItem]], dictionaryItems: [DictionaryItem]) {
        
        let numberOfSentences = sentencesWithLemmas.count
        
        for sentenceIndex in 0..<numberOfSentences {
            
            let sentence = sentencesWithLemmas[sentenceIndex]
            
            for lemmaItem in sentence {
                
                let dictionaryItem = dictionaryItems.first { $0.lemma == lemmaItem.lemma }
                
                guard
                    let dictionaryItem = dictionaryItem,
                    let translation = dictionaryItem.translations.first(where: { $0.mediaId == nil && $0.position == nil })
                else {
                    continue
                }
                
                var newTranslationsForSentence = items[sentenceIndex, default: []]
                newTranslationsForSentence.append(
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
                
                items[sentenceIndex] = newTranslationsForSentence
            }
        }
    }
    
    private func populateItemsWithTranslationsForMedia(sentencesWithLemmas: [[LemmaItem]], translationForMediaId: TranslationItem, dictionaryItem: DictionaryItem) {
        
        let numberOfSentences = sentencesWithLemmas.count
        
        for sentenceIndex in 0..<numberOfSentences {
            
            let sentenceLemmas = sentencesWithLemmas[sentenceIndex]
            
            for lemmaItem in sentenceLemmas {
                
                guard lemmaItem.lemma == dictionaryItem.lemma else {
                    continue
                }
                
                var newTranslationsForSentence = items[sentenceIndex, default: []]
                newTranslationsForSentence.removeAll { $0.textRange != lemmaItem.range }
                newTranslationsForSentence.append(
                    .init(
                        textRange: lemmaItem.range,
                        translation: .init(
                            dictionaryItemId: dictionaryItem.id!,
                            translationId: translationForMediaId.id!,
                            originalText: dictionaryItem.originalText,
                            translatedText: translationForMediaId.text
                        )
                    )
                )
                
                items[sentenceIndex] = newTranslationsForSentence
            }
        }
    }
    
    private func populateItemsWithTranslationsForPositions(
        translationsForPositions: [TranslationItem],
        dictionaryItem: DictionaryItem,
        subtitles: Subtitles
    ) {
        
        let numberOfSentences = subtitles.sentences.count
        
        for sentenceIndex in 0..<numberOfSentences {
            
            let sentence = subtitles.sentences[sentenceIndex]
            let filteredTranslations = translationsForPositions.filter { $0.position?.sentenceIndex == sentenceIndex }
            
            guard !filteredTranslations.isEmpty else {
                continue
            }
            
            var newTranslationsForSentence = items[sentenceIndex, default: []]
            
            
            for translation in filteredTranslations {
                
                guard let translationPosition = translation.position else {
                    continue
                }
                
                let translationRange = translationPosition.getRange(in: sentence.text)
                
                newTranslationsForSentence.removeAll { $0.textRange.overlaps(translationRange) }
                newTranslationsForSentence.append(
                    .init(
                        textRange: translationRange,
                        translation: .init(
                            dictionaryItemId: dictionaryItem.id!,
                            translationId: translation.id!,
                            originalText: dictionaryItem.originalText,
                            translatedText: translation.text
                        )
                    )
                )
                
                items[sentenceIndex] = newTranslationsForSentence
            }
        }
    }
    
    private func populateItemsWithLocalTranslations(
        mediaId: UUID,
        dictionaryItems: [DictionaryItem],
        sentencesWithLemmas: [[LemmaItem]],
        subtitles: Subtitles
    ) {
        
        for dictionaryItem in dictionaryItems {
            
            let translationsForPositions = dictionaryItem.translations.filter { $0.mediaId == mediaId && $0.position != nil }
            let translationForMediaId = dictionaryItem.translations.first { $0.mediaId == mediaId }
            
            if let translationForMediaId = translationForMediaId {
                
                populateItemsWithTranslationsForMedia(
                    sentencesWithLemmas: sentencesWithLemmas,
                    translationForMediaId: translationForMediaId,
                    dictionaryItem: dictionaryItem
                )
            }
            
            if !translationsForPositions.isEmpty {
                
                populateItemsWithTranslationsForPositions(
                    translationsForPositions: translationsForPositions,
                    dictionaryItem: dictionaryItem,
                    subtitles: subtitles
                )
            }
        }
    }
    
    public func sortItemsByTextRange() {
        
        for (key, translations) in items {

            items[key] = translations.sorted { $0.textRange.lowerBound < $1.textRange.lowerBound }
        }
    }
    
    public func prepare(options: AdvancedPlayerSession) async -> Void {
        
        let sentencesWithLemmas = lemmatizeSubtitles(options.subtitles)
        var uniqueLemmas = Set<String>()
        var uniqueWords = Set<String>()
        
        sentencesWithLemmas.forEach { sentenceItems in
            sentenceItems.forEach { item in
                
                uniqueLemmas.insert(item.lemma.lowercased())
            }
        }
        
        var searchFilters = [DictionaryItemFilter]()
        
        for lemma in uniqueLemmas {
            searchFilters.append(.lemma(lemma))
        }
        
        let searchResult = await dictionaryRepository.searchItems(with: searchFilters)
        
        guard case .success(let dictionaryItems) = searchResult else {
            return
        }
        
        populateItemsWithGlobalTranslations(
            sentencesWithLemmas: sentencesWithLemmas,
            dictionaryItems: dictionaryItems
        )
        
        populateItemsWithLocalTranslations(
            mediaId: options.mediaId,
            dictionaryItems: dictionaryItems,
            sentencesWithLemmas: sentencesWithLemmas,
            subtitles: options.subtitles
        )
        
        sortItemsByTextRange()
    }
}
// MARK: - Output methods

extension DefaultProvideTranslationsForSubtitlesUseCase {
    
    public func getTranslations(sentenceIndex: Int) async -> [SubtitlesTranslation] {
        
        return items[sentenceIndex] ?? []
    }
}
