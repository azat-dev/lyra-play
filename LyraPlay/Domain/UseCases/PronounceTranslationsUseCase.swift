//
//  PronounceTranslationsUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.08.2022.
//

import Foundation
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

    var state: Observable<PronounceTranslationsUseCaseState> { get }
}

public protocol PronounceTranslationsUseCase: PronounceTranslationsUseCaseOutput, PronounceTranslationsUseCaseInput {
}

// MARK: - Implementations

public final class DefaultPronounceTranslationsUseCase: PronounceTranslationsUseCase {

    // MARK: - Properties

    private let textToSpeechConverter: TextToSpeechConverter
    private let audioService: AudioService

    public let state: Observable<PronounceTranslationsUseCaseState> = .init(.stopped)

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
    
    public func pronounceSingle(translation: SubtitlesTranslationItem) async -> Void {

        let converted = await convert(translation: translation)
        
        if let originalData = converted.original {
            
            await audioService.play(
                fileId: translation.translationId.uuidString,
                data: originalData
            )
            
            sleep(1)
        }
        
    }

    public func pronounceGroup(translations: [SubtitlesTranslationItem]) async -> Void {

        fatalError("Not implemented")
    }

    public func pause() -> Void {

        fatalError("Not implemented")
    }

    public func stop() -> Void {

        fatalError("Not implemented")
    }
}
