//
//  PronounceTranslationsUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.08.2022.
//

import Foundation
import Combine
import AVFAudio

// MARK: - Interfaces

public enum PronounceTranslationsUseCaseStateData: Equatable {
    
    case single(translation: SubtitlesTranslationItem)
    case group(translations: [SubtitlesTranslationItem], currentTranslationIndex: Int)
}

public enum PronounceTranslationsUseCaseState: Equatable {
    
    case playing(PronounceTranslationsUseCaseStateData)
    case paused(PronounceTranslationsUseCaseStateData)
    case stopped
    case finished
}

public protocol PronounceTranslationsUseCaseInput {
    
    func pronounceSingle(translation: SubtitlesTranslationItem) async -> Void
    
    func pronounceGroup(translations: [SubtitlesTranslationItem]) async -> Void
    
    func pause() -> Void
    
    func stop() -> Void
}

public protocol PronounceTranslationsUseCaseOutput {
    
    var state: CurrentValueSubject<PronounceTranslationsUseCaseState, Never> { get }
}

public protocol PronounceTranslationsUseCase: PronounceTranslationsUseCaseOutput, PronounceTranslationsUseCaseInput {
}

// MARK: - Implementations

public final class DefaultPronounceTranslationsUseCase: PronounceTranslationsUseCase {
    
    // MARK: - Properties
    
    private let textToSpeechConverter: TextToSpeechConverter
    private let audioService: AudioService
    
    public let state = CurrentValueSubject<PronounceTranslationsUseCaseState, Never>(.stopped)
    
    // MARK: - Initializers
    
    public init(
        textToSpeechConverter: TextToSpeechConverter,
        audioService: AudioService
    ) {
        
        self.textToSpeechConverter = textToSpeechConverter
        self.audioService = audioService
    }
}

// MARK: - Input methods

extension DefaultPronounceTranslationsUseCase {
    
    private func convert(translation: SubtitlesTranslationItem) async -> (original: Data?, translated: Data?) {
        
        let results = await [
            
            textToSpeechConverter.convert(
                text: translation.originalText,
                language: translation.originalTextLanguage
            ),
            textToSpeechConverter.convert(
                text: translation.translatedText,
                language: translation.translatedTextLanguage
            )
        ]
        
        return (
            try? results[0].get(),
            try? results[1].get()
        )
    }
    
    private func pronounce(translation: SubtitlesTranslationItem) async -> Bool {
        
        let converted = await convert(translation: translation)
        
        if let originalData = converted.original {
            
            let prepareResult = audioService.prepare(
                fileId: translation.translationId.uuidString,
                data: originalData
            )
            
            guard case .success = prepareResult else {
                return false
            }
            
            let result = await audioService.playAndWaitForEnd()
            guard case .success = result else {
                return false
            }
            
            // Clean finished result
            let _ = audioService.stop()
        }
        
        if let translatedData = converted.translated {
            
            let prepareResult = audioService.prepare(
                fileId: translation.translationId.uuidString,
                data: translatedData
            )
            
            guard case .success = prepareResult else {
                return false
            }
        }
        
        return true
    }
    
    public func pronounceSingle(translation: SubtitlesTranslationItem) async -> Void {
        
        state.value = .playing(.single(translation: translation))
        let _ = await pronounce(translation: translation)
        state.value = .finished
    }
    
    public func pronounceGroup(translations: [SubtitlesTranslationItem]) async -> Void {
        
        for index in 0..<translations.count {
            
            let translation = translations[index]
            
            state.value = .playing(.group(translations: translations, currentTranslationIndex: index))
            let success = await pronounce(translation: translation)
            
            if !success {
                break
            }
        }
        
        state.value = .finished
    }
    
    public func pause() -> Void {
        
        guard case .playing = state.value else {
            return
        }
        
        let _ = audioService.pause()
    }
    
    public func stop() -> Void {
        
        let _ = audioService.stop()
    }
}
