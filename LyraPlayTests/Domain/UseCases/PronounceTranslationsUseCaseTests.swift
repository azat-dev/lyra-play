//
//  PronounceTranslationsUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 08.08.2022.
//

import XCTest
import LyraPlay

class PronounceTranslationsUseCaseTests: XCTestCase {
    
    typealias SUT = (
        useCase: PronounceTranslationsUseCase,
        textToSpeechConverter: TextToSpeechConverter,
        audioService: AudioServiceMock
    )
    
    func createSUT() -> SUT {
        
        let textToSpeechConverter = TextToSpeechConverterMock()
        let audioService = AudioServiceMock()
        
        let useCase = DefaultPronounceTranslationsUseCase(
            textToSpeechConverter: textToSpeechConverter,
            audioService: audioService
        )
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            textToSpeechConverter,
            audioService
        )
    }
    
    func anyTranslation() -> SubtitlesTranslationItem {
        return .init(
            dictionaryItemId: UUID(),
            translationId: UUID(),
            originalText: "Apple",
            translatedText: "Яблоко"
        )
    }
    
    func anyGroupTranslations() -> [SubtitlesTranslationItem] {
        return [
            anyTranslation(),
            anyTranslation(),
        ]
    }
    
    func test_pronounceSingle() async throws {
        
        let sut = createSUT()
        
        let testTranslation = anyTranslation()
        
        let expectedStateItems: [PronounceTranslationsUseCaseState] = [
            .stopped,
            .playing(.single(translation: testTranslation)),
            .finished
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        
        stateSequence.observe(sut.useCase.state)
        
        await sut.useCase.pronounceSingle(
            translation: testTranslation
        )
        
        stateSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func test_pronounceGroup() async throws {
        
        let sut = createSUT()
        
        let testTranslations = anyGroupTranslations()
        
        let expectedStateItems: [PronounceTranslationsUseCaseState] = [
            .stopped,
            .playing(.group(translations: testTranslations, currentTranslationIndex: 0)),
            .playing(.group(translations: testTranslations, currentTranslationIndex: 1)),
            .finished
        ]
        let stateSequence = self.expectSequence(expectedStateItems)
        
        stateSequence.observe(sut.useCase.state)
        
        await sut.useCase.pronounceGroup(translations: testTranslations)
        
        stateSequence.wait(timeout: 5, enforceOrder: true)
    }

    func test_change_state_single(expectedStateItems: [PronounceTranslationsUseCaseState]) async throws {
        
        let sut = createSUT()
        
        let testTranslation = anyTranslation()
        
        let expectedStateItems: [PronounceTranslationsUseCaseState] = [
            .stopped,
            .playing(.single(translation: testTranslation)),
            .paused(.single(translation: testTranslation)),
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        
        let controlledState = Observable(sut.useCase.state.value)
        
        sut.useCase.state.observe(on: self) { newState in
            
            if case .playing = newState {
                
                controlledState.value = newState
                sut.useCase.pause()
                return
            }
            
            controlledState.value = newState
        }
        
        stateSequence.observe(controlledState)
        stateSequence.wait(timeout: 1, enforceOrder: true)
        
        controlledState.remove(observer: self)
        sut.useCase.state.remove(observer: self)
    }
    
    func test_pause__playing_single() async throws {
        
        let sut = createSUT()
        
        let testTranslation = anyTranslation()
        
        let expectedStateItems: [PronounceTranslationsUseCaseState] = [
            .stopped,
            .playing(.single(translation: testTranslation)),
            .paused(.single(translation: testTranslation)),
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        
        let controlledState = Observable(sut.useCase.state.value)
        
        sut.useCase.state.observe(on: self) { newState in
            
            if case .playing = newState {
                
                controlledState.value = newState
                sut.useCase.pause()
                return
            }
            
            controlledState.value = newState
        }
        
        stateSequence.observe(controlledState)
        stateSequence.wait(timeout: 5, enforceOrder: true)
        
        controlledState.remove(observer: self)
        sut.useCase.state.remove(observer: self)
    }
}

// MARK: - Helpers

struct ExpectedPronounceTranslationsUseCaseOutput: Equatable {
    
    var state: PronounceTranslationsUseCaseState
    
    init(
        state: PronounceTranslationsUseCaseState
    ) {
        
        self.state = state
    }
    
    init(from source: PronounceTranslationsUseCaseOutput) {
        
        self.state = source.state.value
    }
    
    static func initialValue() -> ExpectedPronounceTranslationsUseCaseOutput {
        
        return .init(state: .stopped)
    }
}

// MARK: - Mocks

final class TextToSpeechConverterMock: TextToSpeechConverter {
    
    func convert(text: String, language: String) async -> Result<Data, TextToSpeechConverterError> {
        
        let bundle = Bundle(for: type(of: self ))
        let url = bundle.url(forResource: "test_music_with_tags_short", withExtension: "mp3")!
        
        let testFileData = try! Data(contentsOf: url)
        
        return .success(testFileData)
    }
}
