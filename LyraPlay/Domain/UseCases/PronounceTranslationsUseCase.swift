//
//  PronounceTranslationsUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.08.2022.
//

import Foundation

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

    func pronounceSingle(translation: SubtitlesTranslationItem) -> Void

    func pronounceGroup(translations: [SubtitlesTranslationItem]) -> Void

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

    public let state: Observable<PronounceTranslationsUseCaseState> = .init(.stopped)

    // MARK: - Initializers

    public init(textToSpeechConverter: TextToSpeechConverter) {

        self.textToSpeechConverter = textToSpeechConverter
    }
}

// MARK: - Input methods

extension DefaultPronounceTranslationsUseCase {

    public func pronounceSingle(translation: SubtitlesTranslationItem) -> Void {

        fatalError("Not implemented")
    }

    public func pronounceGroup(translations: [SubtitlesTranslationItem]) -> Void {

        fatalError("Not implemented")
    }

    public func pause() -> Void {

        fatalError("Not implemented")
    }

    public func stop() -> Void {

        fatalError("Not implemented")
    }
}
