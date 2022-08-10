//
//  PlayMediaWithTranslationsUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.08.2022.
//

import Foundation

// MARK: - Interfaces

public enum PlayMediaWithTranslationsUseCaseError: Error {

    case mediaFileNotFound
}

public enum PlayMediaWithTranslationsUseCaseState: Equatable {

    case initial
    case playing(subtitlesPosition: SubtitlesPosition?)
    case pronouncingTranslations(subtitlesPosition: SubtitlesPosition?, data: PronounceTranslationsUseCaseStateData)
    case paused(subtitlesPosition: SubtitlesPosition?)
    case stopped
    case finished
}

public protocol PlayMediaWithTranslationsUseCaseInput {

    func play(
        mediaId: UUID,
        nativeLanguage: String,
        learningLanguage: String,
        at: TimeInterval
    ) -> Result<Void, PlayMediaWithTranslationsUseCaseError>

    func pause() -> Result<Void, PlayMediaWithTranslationsUseCaseError>

    func stop() -> Result<Void, PlayMediaWithTranslationsUseCaseError>
}

public protocol PlayMediaWithTranslationsUseCaseOutput {

    var state: Observable<PlayMediaWithTranslationsUseCaseState> { get }
}

public protocol PlayMediaWithTranslationsUseCase: PlayMediaWithTranslationsUseCaseOutput, PlayMediaWithTranslationsUseCaseInput {
}

// MARK: - Implementations

public final class DefaultPlayMediaWithTranslationsUseCase: PlayMediaWithTranslationsUseCase {

    // MARK: - Properties

    private let loadSubtitlesUseCase: LoadSubtitlesUseCase
    private let playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory
    private let provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase
    private let pronounceTranslationsUseCase: PronounceTranslationsUseCase
    private let translationsScheduler: Scheduler

    public let state: Observable<PlayMediaWithTranslationsUseCaseState> = .init(.initial)

    // MARK: - Initializers

    public init(
        loadSubtitlesUseCase: LoadSubtitlesUseCase,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase,
        pronounceTranslationsUseCase: PronounceTranslationsUseCase,
        translationsScheduler: Scheduler
    ) {

        self.loadSubtitlesUseCase = loadSubtitlesUseCase
        self.playSubtitlesUseCaseFactory = playSubtitlesUseCaseFactory
        self.provideTranslationsToPlayUseCase = provideTranslationsToPlayUseCase
        self.pronounceTranslationsUseCase = pronounceTranslationsUseCase
        self.translationsScheduler = translationsScheduler
    }
}

// MARK: - Input methods

extension DefaultPlayMediaWithTranslationsUseCase {

    public func play(
        mediaId: UUID,
        nativeLanguage: String,
        learningLanguage: String,
        at: TimeInterval
    ) -> Result<Void, PlayMediaWithTranslationsUseCaseError> {

        fatalError("Not implemented")
    }

    public func pause() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {

        fatalError("Not implemented")
    }

    public func stop() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {

        fatalError("Not implemented")
    }
}
