//
//  ProvideTranslationsForSubtitlesUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 05.08.2022.
//

import XCTest
import LyraPlay

class ProvideTranslationsForSubtitlesUseCaseTests: XCTestCase {
    
    typealias SUT = (
        useCase: ProvideTranslationsForSubtitlesUseCase,
        dictionaryRepository: DictionaryRepository,
        textSplitter: TextSplitter,
        lemmatizer: Lemmatizer
    )
    
    func createSUT() -> SUT {
        
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let coreDataStore = try! CoreDataStore(storeURL: storeURL)
        
        let dictionaryRepository = CoreDataDictionaryRepository(coreDataStore: coreDataStore)
        
        let textSplitter = DefaultTextSplitter()
        let lemmatizer = DefaultLemmatizer()
        
        let useCase = DefaultProvideTranslationsForSubtitlesUseCase(
            dictionaryRepository: dictionaryRepository,
            textSplitter: textSplitter,
            lemmatizer: lemmatizer
        )
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            dictionaryRepository,
            textSplitter,
            lemmatizer
        )
    }
    
    // MARK: - Helpers
    
    func anyPlayerSession(mediaId: UUID, subtitles: Subtitles) -> AdvancedPlayerSession {
        return .init(
            mediaId: mediaId,
            nativeLanguage: "",
            learningLanguage: "",
            subtitles: subtitles
        )
    }
    
    func anyMediaId() -> UUID {
        return .init(uuidString: "00000000-0000-0000-0000-000000000000")!
    }
    
    func anyTranslationId() -> UUID {
        return .init(uuidString: "00000000-0000-0000-0000-000000000000")!
    }
    
    func anySentenceIndex() -> Int {
        return .init()
    }
    
    func emptySubtitles() -> Subtitles {
        return .init(duration: 0, sentences: [])
    }
    
    func anySubtitles(sentences: [String]) -> Subtitles {
        
        return .init(
            duration: TimeInterval(sentences.count),
            sentences: (0..<sentences.count).map {
                return .init(startTime: TimeInterval($0), text: sentences[$0], components: [])
            }
        )
    }
    
    func anyTranslationItem(text: String, position: TranslationItemPosition? = nil, id: UUID? = nil) -> TranslationItem {
        
        return .init(
            id: id ?? anyTranslationId(),
            text: text,
            mediaId: anyMediaId(),
            timeMark: nil,
            position: position
        )
    }
    
    func anyDictionaryItem(
        originalText: String,
        lemma: String,
        translations: [TranslationItem]
    ) -> DictionaryItem {
        
        return .init(
            id: nil,
            originalText: originalText,
            lemma: lemma,
            language: "",
            translations: translations
        )
    }
    
    // MARK: - Test Methods
    
    func test_prepare__empty_subtitles() async throws {
        
        let sut = createSUT()
        
        // Given
        let mediaId = anyMediaId()
        let testOptions = anyPlayerSession(
            mediaId: mediaId,
            subtitles: emptySubtitles()
        )
        
        // When
        await sut.useCase.prepare(
            options: testOptions
        )
    }
    
    func test_getTranslations__by_lemmas_and_original_texts() async throws {
        
        let sut = createSUT()
        
        // Given
//        let sentences = [
//            "Apple, pear",
//            "Banana",
//            "orange"
//        ]
        
        let subtitles = Subtitles(
            duration: 10,
            sentences: [
                .anySentence(at: 0, duration: 0, timeMarks: nil, text: "Apple, pear"),
                .anySentence(at: 1, duration: 0, timeMarks: nil, text: "Banana"),
                .anySentence(at: 2, duration: 0, timeMarks: nil, text: "orange"),
            ]
        )
        
        let sentences = subtitles.sentences
        
        let putTranslationResult = await sut.dictionaryRepository.putItem(
            anyDictionaryItem(
                originalText: "apple",
                lemma: "apple",
                translations: [
                anyTranslationItem(text: "translatedapple")
            ])
        )
        
        let savedDictionaryItemWithLemma = try AssertResultSucceded(putTranslationResult)
        
        let putTranslationWithoutLemmaResult = await sut.dictionaryRepository.putItem(
            anyDictionaryItem(
                originalText: "banana",
                lemma: "",
                translations: [
                    .init(id: UUID(), text: "translatedbanana", mediaId: nil, timeMark: nil, position: nil)
                ]
            )
        )
        
        let savedDictionaryItemWithoutLemma = try AssertResultSucceded(putTranslationWithoutLemmaResult)
        await sut.useCase.prepare(options: anyPlayerSession(mediaId: anyMediaId(), subtitles: subtitles))
        
        // When
        
        let receivedItems1 = await sut.useCase.getTranslations(sentenceIndex: 0)

        // Then
        let expectedItems1: [SubtitlesTranslation] = [
            .init(
                textRange: sentences[0].text.range(of: "Apple")!,
                translation: .init(
                    dictionaryItemId: savedDictionaryItemWithLemma.id!,
                    translationId: anyTranslationId(),
                    originalText: savedDictionaryItemWithLemma.originalText,
                    translatedText: "translatedapple"
                )
            )
        ]

        AssertEqualReadable(receivedItems1, expectedItems1)
        
        
        // When
        let receivedItems2 = await sut.useCase.getTranslations(sentenceIndex: 1)
        
        // Then
        let expectedItems2: [SubtitlesTranslation] = [
            .init(
                textRange: sentences[1].text.range(of: "Banana")!,
                translation: .init(
                    dictionaryItemId: savedDictionaryItemWithoutLemma.id!,
                    translationId: savedDictionaryItemWithoutLemma.translations.first!.id!,
                    originalText: savedDictionaryItemWithoutLemma.originalText,
                    translatedText: "translatedbanana"
                )
            )
        ]
        
        AssertEqualReadable(receivedItems2, expectedItems2)
    }
    
    func test_getTranslations__with_text_ranges() async throws {
        
        let sut = createSUT()

        // Given
        let sentence1 = "Apple, pear, apple"
        let sentence2 = "banana apple"
        
        let sentences = [
            sentence1,
            sentence2
        ]
        
        let subtitles = anySubtitles(sentences: sentences)
        
        let putDictionaryItemResult = await sut.dictionaryRepository.putItem(
            anyDictionaryItem(
                originalText: "apple",
                lemma: "apple",
                translations: [
                    anyTranslationItem(
                        text: "translation_for_lemma",
                        id: anyTranslationId()
                    ),
                    anyTranslationItem(
                        text: "translation_for_range",
                        position: .init(
                            sentenceIndex: 0,
                            textRange: .textRange(of: "Apple", in: sentence1)!
                        ),
                        id: anyTranslationId()
                    )
                ]
            )
        )
        
        let savedDictionaryItem = try AssertResultSucceded(putDictionaryItemResult)
        
        let dictionaryId = savedDictionaryItem.id!
        let translations = savedDictionaryItem.translations
        
        let translationWithLemma = translations[0]
        let translationWithRange = translations[1]
        
        // When
        await sut.useCase.prepare(options: anyPlayerSession(mediaId: anyMediaId(), subtitles: subtitles))
        
        // Then
        let expectedItems1: [SubtitlesTranslation] = [
            .init(
                textRange: sentence1.range(of: "Apple")!,
                translation: .init(
                    dictionaryItemId: dictionaryId,
                    translationId: translations[0].id!,
                    originalText: savedDictionaryItem.originalText,
                    translatedText: translationWithRange.text
                )
            ),
            .init(
                textRange: sentence1.range(of: "apple")!,
                translation: .init(
                    dictionaryItemId: savedDictionaryItem.id!,
                    translationId: translations[1].id!,
                    originalText: savedDictionaryItem.originalText,
                    translatedText: translationWithLemma.text
                )
            ),
        ]
        
        let receivedItems1 = await sut.useCase.getTranslations(sentenceIndex: 0)
        AssertEqualReadable(receivedItems1, expectedItems1)
        
        let expectedItems2: [SubtitlesTranslation] = [
            .init(
                textRange: sentence2.range(of: "apple")!,
                translation: .init(
                    dictionaryItemId: dictionaryId,
                    translationId: translations[0].id!,
                    originalText: savedDictionaryItem.originalText,
                    translatedText: translationWithLemma.text
                )
            ),
        ]
        
        let receivedItems2 = await sut.useCase.getTranslations(sentenceIndex: 1)
        AssertEqualReadable(receivedItems2, expectedItems2)
    }
}
