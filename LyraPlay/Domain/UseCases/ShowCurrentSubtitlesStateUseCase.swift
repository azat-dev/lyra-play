//
//  ShowCurrentSubtitlesStateUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.07.2022.
//

import Foundation

// MARK: - Interfaces

public struct SubtitlesPosition {

    public var sentenceIndex: Int
    public var timeMarkIndex: Int?

    public init(
        sentenceIndex: Int,
        timeMarkIndex: Int?
    ) {

        self.sentenceIndex = sentenceIndex
        self.timeMarkIndex = timeMarkIndex
    }
}

public struct CurrentSubtitlesState {

    public var isPlaying: Bool
    public var position: SubtitlesPosition?

    public init(
        isPlaying: Bool,
        position: SubtitlesPosition?
    ) {

        self.isPlaying = isPlaying
        self.position = position
    }
}

public protocol ShowCurrentSubtitlesStateUseCaseInput {

    func updateState(state: CurrentSubtitlesState) -> Void
}

public protocol ShowCurrentSubtitlesStateUseCaseOutput {

    var state: Observable<CurrentSubtitlesState> { get }
}

public protocol ShowCurrentSubtitlesStateUseCase: ShowCurrentSubtitlesStateUseCaseOutput, ShowCurrentSubtitlesStateUseCaseInput {
}

// MARK: - Implementations

public final class DefaultShowCurrentSubtitlesStateUseCase: ShowCurrentSubtitlesStateUseCase {

    // MARK: - Properties

    public let state: Observable<CurrentSubtitlesState> = Observable(.init(isPlaying: false, position: nil))

    // MARK: - Initializers

    public init() {}
}

// MARK: - Input methods

extension DefaultShowCurrentSubtitlesStateUseCase {

    public func updateState(state newState: CurrentSubtitlesState) -> Void {

        state.value = newState
    }
}
