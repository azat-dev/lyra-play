//
//  PlaySubtitlesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation
import Combine

public protocol PlaySubtitlesUseCaseDelegate: AnyObject {
    
    func playSubtitlesUseCaseWillChange(
        fromPosition: SubtitlesPosition?,
        toPosition: SubtitlesPosition?,
        stop: inout Bool
    )
    
    func playSubtitlesUseCaseDidChange(position: SubtitlesPosition?)
    
    func playSubtitlesUseCaseDidFinish()
}

public enum PlaySubtitlesUseCaseState: Equatable {

    case initial
    case playing(position: SubtitlesPosition?)
    case paused(position: SubtitlesPosition?)
    case stopped
    case finished
}

public protocol PlaySubtitlesUseCaseInput: AnyObject {

    func play() -> Void

    func play(atTime: TimeInterval) -> Void

    func pause() -> Void

    func stop() -> Void
}

public protocol PlaySubtitlesUseCaseOutput: AnyObject {

    var state: CurrentValueSubject<PlaySubtitlesUseCaseState, Never> { get }

    var willChangePosition: PassthroughSubject<WillChangeSubtitlesPositionData, Never> { get }
}

public protocol PlaySubtitlesUseCase: PlaySubtitlesUseCaseOutput, PlaySubtitlesUseCaseInput {

}
