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
        interrupt: inout Bool
    )
    
    func playSubtitlesUseCaseDidChange(position: SubtitlesPosition?)
    
    func playSubtitlesUseCaseDidFinish()
}

public enum PlaySubtitlesUseCaseState: Equatable {

    case initial
    case playing
    case paused
    case stopped
    case finished
}

public protocol PlaySubtitlesUseCaseInput: AnyObject {

    func play(atTime: TimeInterval) -> Void
    
    func resume() -> Void

    func pause() -> Void

    func stop() -> Void
    
    func setTime(_ time: TimeInterval)
}

public protocol PlaySubtitlesUseCaseOutput: AnyObject {

    var state: CurrentValueSubject<PlaySubtitlesUseCaseState, Never> { get }
    
    var subtitlesPosition: CurrentValueSubject<SubtitlesPosition?, Never> { get }

    var delegate: PlaySubtitlesUseCaseDelegate? { get set }
}

public protocol PlaySubtitlesUseCase: PlaySubtitlesUseCaseOutput, PlaySubtitlesUseCaseInput {

}
