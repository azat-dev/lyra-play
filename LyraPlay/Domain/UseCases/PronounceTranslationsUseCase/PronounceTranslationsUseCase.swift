//
//  PronounceTranslationsUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation
import Combine

public enum PronounceTranslationsUseCaseStateData: Equatable {

    case single(translation: SubtitlesTranslationItem)
    case group(translations: [SubtitlesTranslationItem], currentTranslationIndex: Int?)
}

public enum PronounceTranslationsUseCaseState: Equatable {

    case loading(PronounceTranslationsUseCaseStateData)
    case playing(PronounceTranslationsUseCaseStateData)
    case paused(PronounceTranslationsUseCaseStateData)
    case stopped
    case finished
}

public protocol PronounceTranslationsUseCaseInput {

    func pronounceSingle(translation: SubtitlesTranslationItem) -> AsyncThrowingStream<PronounceTranslationsUseCaseState, Error>

    func pronounceGroup(translations: [SubtitlesTranslationItem]) -> AsyncThrowingStream<PronounceTranslationsUseCaseState, Error>

    func pause() -> Void

    func stop() -> Void
}

public protocol PronounceTranslationsUseCaseOutput {

    var state: CurrentValueSubject<PronounceTranslationsUseCaseState, Never> { get }
}

public protocol PronounceTranslationsUseCase: PronounceTranslationsUseCaseOutput, PronounceTranslationsUseCaseInput {

}
