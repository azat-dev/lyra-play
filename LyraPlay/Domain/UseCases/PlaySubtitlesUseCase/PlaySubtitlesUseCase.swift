//
//  PlaySubtitlesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation
import Combine

public enum PlaySubtitlesUseCaseState: Equatable {

    case initial
    case playing(position: SubtitlesPosition?)
    case paused(position: SubtitlesPosition?)
    case stopped
    case finished
}

public protocol PlaySubtitlesUseCaseInput {

    func play() -> Void

    func play(atTime: TimeInterval) -> Void

    func pause() -> Void

    func stop() -> Void
}

public protocol PlaySubtitlesUseCaseOutput {

    var state: CurrentValueSubject<PlaySubtitlesUseCaseState, Never> { get }

    var willChangePosition: PassthroughSubject<WillChangeSubtitlesPositionData, Never> { get }
}

public protocol PlaySubtitlesUseCase: PlaySubtitlesUseCaseOutput, PlaySubtitlesUseCaseInput {

}
