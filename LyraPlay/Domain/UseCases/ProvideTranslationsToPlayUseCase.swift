//
//  ProvideTranslationsToPlayUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.08.2022.
//

import Foundation

// MARK: - Interfaces

public enum TranslationsToPlayData: Equatable {

    case single(translation: SubtitlesTranslationItem)
    case groupAfterSentence(items: [SubtitlesTranslationItem])
}

public struct TranslationsToPlay {

    public var time: TimeInterval
    public var data: TranslationsToPlayData

    public init(
        time: TimeInterval,
        data: TranslationsToPlayData
    ) {

        self.time = time
        self.data = data
    }
}

public protocol ProvideTranslationsToPlayUseCaseInput {

    func prepare(params: AdvancedPlayerSession) async -> Void

    func beginNextExecution(from time: TimeInterval?) -> TimeInterval?

    func getTimeOfNextEvent() -> TimeInterval?

    func moveToNextEvent() -> TimeInterval?
}

public protocol ProvideTranslationsToPlayUseCaseOutput {

    var lastEventTime: TimeInterval? { get }

    var currentItem: TranslationsToPlay? { get }
}

public protocol ProvideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCaseOutput, ProvideTranslationsToPlayUseCaseInput {
}

// MARK: - Implementations

public final class DefaultProvideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase {

    // MARK: - Properties

    private let provideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCase

    public let lastEventTime: TimeInterval? = nil
    
    public let currentItem: TranslationsToPlay? = nil

    // MARK: - Initializers

    public init(provideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCase) {

        self.provideTranslationsForSubtitlesUseCase = provideTranslationsForSubtitlesUseCase
    }
}

// MARK: - Input methods

extension DefaultProvideTranslationsToPlayUseCase {

    public func prepare(params: AdvancedPlayerSession) -> Void {

        fatalError("Not implemented")
    }

    public func beginNextExecution(from time: TimeInterval?) -> TimeInterval? {

        fatalError("Not implemented")
    }

    public func getTimeOfNextEvent() -> TimeInterval? {

        fatalError("Not implemented")
    }

    public func moveToNextEvent() -> TimeInterval? {

        fatalError("Not implemented")
    }
}
