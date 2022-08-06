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
        textSplitter: TextSplitterMock,
        lemmatizer: Lemmatizer
    )
    
    func createSUT() -> SUT {
        
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let coreDataStore = try! CoreDataStore(storeURL: storeURL)
        
        let dictionaryRepository = CoreDataDictionaryRepository(coreDataStore: coreDataStore)
        
        let textSplitter = TextSplitterMock()
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
    
    func anyOptions(mediaId: UUID, subtitles: Subtitles) -> ProvideTranslationsForSubtitlesUseCaseOptions {
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
    
    func test_prepare__empty_subtitles() async throws {
        
        let sut = createSUT()
        
        let mediaId = anyMediaId()
        let testOptions = anyOptions(mediaId: mediaId, subtitles: emptySubtitles())
        
        await sut.useCase.prepare(
            options: testOptions
        )
    }
    
    func test_getTranslations__by_lemma() async throws {
        
        let sut = createSUT()
        
        let sentences = [
            "Apple, pear",
            "Banana"
        ]
        
        let subtitles = anySubtitles(sentences: sentences)
        
        let putTranslationResult = await sut.dictionaryRepository.putItem(
            anyDictionaryItem(
                originalText: "apple",
                lemma: "apple",
                translations: [
                anyTranslationItem(text: "translatedapple")
            ])
        )
        
        let savedDictionaryItem = try AssertResultSucceded(putTranslationResult)
        
        await sut.useCase.prepare(options: anyOptions(mediaId: anyMediaId(), subtitles: subtitles))
        let receivedItems = await sut.useCase.getTranslations(
            sentenceIndex: 0
        )
        
        let expectedItems: [SubtitlesTranslation] = [
            .init(
                textRange: sentences[0].range(of: "Apple")!,
                translation: .init(
                    dictionaryItemId: savedDictionaryItem.id!,
                    translationId: anyTranslationId(),
                    originalText: savedDictionaryItem.originalText,
                    translatedText: "translatedapple"
                )
            )
        ]
        AssertEqualReadable(receivedItems, expectedItems)
    }
    
    func test_getTranslations__with_text_ranges() async throws {
        
        let sut = createSUT()
        
        let sentence1 = "Apple, pear, apple"
        let sentence2 = "apple"
        
        let sentences = [
            sentence1,
            sentence2
        ]
        
        let subtitles = anySubtitles(sentences: sentences)
        
        let range = sentence1.range(of: "Apple")!
        let encodedRange = range.lowerBound.utf16Offset(in: sentence1)..<range.upperBound.utf16Offset(in: sentence1)
        
        
        let putDictionaryItemResult = await sut.dictionaryRepository.putItem(
            anyDictionaryItem(
                originalText: "apple",
                lemma: "apple",
                translations: [
                    anyTranslationItem(text: "translation_for_lemma"),
                    anyTranslationItem(
                        text: "translation_for_range",
                        position: .init(
                            sentenceIndex: 0,
                            textRange: encodedRange
                        ),
                        id: UUID()
                    )
                ]
            )
        )
        
        let savedDictionaryItem = try AssertResultSucceded(putDictionaryItemResult)
        
        await sut.useCase.prepare(options: anyOptions(mediaId: anyMediaId(), subtitles: subtitles))
        
        
        let expectedItems: [SubtitlesTranslation] = [
            .init(
                textRange: sentence1.range(of: "Apple")!,
                translation: .init(
                    dictionaryItemId: savedDictionaryItem.id!,
                    translationId: anyTranslationId(),
                    originalText: savedDictionaryItem.originalText,
                    translatedText: "translation_for_range"
                )
            ),
            .init(
                textRange: sentence2.range(of: "apple")!,
                translation: .init(
                    dictionaryItemId: savedDictionaryItem.id!,
                    translationId: anyTranslationId(),
                    originalText: savedDictionaryItem.originalText,
                    translatedText: "translation_for_lemma"
                )
            ),
        ]
        
        let receivedItems = await sut.useCase.getTranslations(
            sentenceIndex: 0
        )
        AssertEqualReadable(receivedItems, expectedItems)
    }
}
