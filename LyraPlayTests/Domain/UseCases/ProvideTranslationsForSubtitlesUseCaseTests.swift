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
    
    func anyTranslationItem(text: String) -> TranslationItem {
        
        return .init(
            text: text,
            mediaId: anyMediaId(),
            timeMark: nil,
            position: nil
        )
    }
    
    func anyDictionaryItem(
        originalText: String,
        lemma: String,
        translations: [TranslationItem]
    ) -> DictionaryItem {
        
        return .init(
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
    
    func test_getTranslations() async throws {
        
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
                    translationId: UUID(),
                    originalText: savedDictionaryItem.originalText,
                    translatedText: "translatedapple"
                )
            )
        ]
        AssertEqualReadable(receivedItems, expectedItems)
    }
}
