//
//  ProvideTranslationsForSubtitlesUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class ProvideTranslationsForSubtitlesUseCaseImpl: ProvideTranslationsForSubtitlesUseCase {

    private typealias SentenceIndex = Int
    
    // MARK: - Properties

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

// MARK: - Input Methods

extension ProvideTranslationsForSubtitlesUseCaseImpl {
    
    private func lemmatizeSubtitles(_ subtitles: Subtitles) -> [[LemmaItem]] {
        
        return subtitles.sentences.map { sentence in
            lemmatizer.lemmatize(text: sentence.text).map {
                return .init(lemma: $0.lemma.lowercased(), range: $0.range)
            }
        }
    }
    
    private func splitSubtitlesToWords(_ subtitles: Subtitles) -> [[TextComponent]] {
        
        return subtitles.sentences.map { sentence in
            return textSplitter.split(text: sentence.text)
        }
    }
    
    private func populateItemsWithGlobalTranslations<T>(
        sentences: [[T]],
        dictionaryItems: [DictionaryItem],
        findDictionaryItemBy: (_ sentenceIndex: Int, _ dictionaryItem: DictionaryItem, _ component: T) -> Bool,
        rangeOfComponent: (T) -> Range<String.Index>
    ) {
        
        let numberOfSentences = sentences.count
        
        for sentenceIndex in 0..<numberOfSentences {
            
            let sentence = sentences[sentenceIndex]
            
            for component in sentence {
                
                let foundDictionaryItem = dictionaryItems.first { findDictionaryItemBy(sentenceIndex, $0, component)}
                
                guard
                    let dictionaryItem = foundDictionaryItem,
                    let translation = dictionaryItem.translations.first(where: { $0.mediaId == nil && $0.position == nil })
                else {
                    continue
                }
                
                let componentRange = rangeOfComponent(component)
                let existingItems = items[sentenceIndex, default: []]
                
                guard !existingItems.contains(where: { $0.textRange.overlaps(componentRange) }) else {
                    continue
                }
                
                var newTranslationsForSentence = items[sentenceIndex, default: []]
                newTranslationsForSentence.append(
                    .init(
                        textRange: componentRange,
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
        
        let subtitles = options.subtitles
        let sentencesWithLemmas = lemmatizeSubtitles(options.subtitles)
        let sentencesWithComponents = splitSubtitlesToWords(options.subtitles)
        
        var uniqueLemmas = Set<String>()
        var uniqueComponents = Set<String>()
        
        sentencesWithLemmas.forEach { sentenceItems in
            sentenceItems.forEach { item in
                
                uniqueLemmas.insert(item.lemma.lowercased())
            }
        }

        var textsForRanges = [[Range<String.Index>: String]]()
        
        for sentenceIndex in sentencesWithComponents.indices {

            let sentence = subtitles.sentences[sentenceIndex]
            let text = sentence.text

            let items = sentencesWithComponents[sentenceIndex]
            var sentenceComponents = [Range<String.Index>: String]()
            
            for item in items {
                
                guard case .word = item.type else {
                    continue
                }
                
                let range = item.range
                let rangeText = String(text[range]).lowercased()
                
                
                sentenceComponents[range] = rangeText
                uniqueComponents.insert(rangeText)
            }
            
            textsForRanges.append(sentenceComponents)
        }
        
        var searchFilters = [DictionaryItemFilter]()
        
        for lemma in uniqueLemmas {
            searchFilters.append(.lemma(lemma))
        }
        
        for component in uniqueComponents {
            searchFilters.append(.originalText(component))
        }
        
        let searchResult = await dictionaryRepository.searchItems(with: searchFilters)
        
        guard case .success(let dictionaryItems) = searchResult else {
            return
        }
        
        populateItemsWithLocalTranslations(
            mediaId: options.mediaId,
            dictionaryItems: dictionaryItems,
            sentencesWithLemmas: sentencesWithLemmas,
            subtitles: options.subtitles
        )

        populateItemsWithGlobalTranslations(
            sentences: sentencesWithComponents,
            dictionaryItems: dictionaryItems,
            findDictionaryItemBy: { sentenceIndex, dictionaryItem, component in
                
                let text = textsForRanges[sentenceIndex][component.range]
                return dictionaryItem.originalText.lowercased() == text
            },
            rangeOfComponent: { $0.range }
        )
        
        populateItemsWithGlobalTranslations(
            sentences: sentencesWithLemmas,
            dictionaryItems: dictionaryItems,
            findDictionaryItemBy: { sentenceIndex, dictionaryItem, component in

                return dictionaryItem.lemma.lowercased() == component.lemma.lowercased()
            },
            rangeOfComponent: { $0.range }
        )
        
        sortItemsByTextRange()
    }
}


// MARK: - Output Methods

extension ProvideTranslationsForSubtitlesUseCaseImpl {
    
    public func getTranslations(sentenceIndex: Int) async -> [SubtitlesTranslation] {
        
        return items[sentenceIndex] ?? []
    }
}
