//
//  PlayMediaUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation
import Combine

public enum PlayMediaUseCaseError: Error {

    case trackNotFound
    case noActiveTrack
    case internalError(Error?)
}

public enum PlayMediaUseCaseState: Equatable {

    case initial
    case loading(mediaId: UUID)
    case loaded(mediaId: UUID)
    case failedLoad(mediaId: UUID)
    case playing(mediaId: UUID)
    case stopped
    case paused(mediaId: UUID, time: TimeInterval)
    case finished(mediaId: UUID)
}

public protocol PlayMediaUseCaseInput: AnyObject {

    func prepare(mediaId: UUID) async -> Result<Void, PlayMediaUseCaseError>

    func play() -> Result<Void, PlayMediaUseCaseError>

    func play(atTime: TimeInterval) -> Result<Void, PlayMediaUseCaseError>

    func pause() -> Result<Void, PlayMediaUseCaseError>

    func stop() -> Result<Void, PlayMediaUseCaseError>
    
    func togglePlay() -> Result<Void, PlayMediaUseCaseError>
}

public protocol PlayMediaUseCaseOutput: AnyObject {

    var state: CurrentValueSubject<PlayMediaUseCaseState, Never> { get }
}

public protocol PlayMediaUseCase: PlayMediaUseCaseOutput, PlayMediaUseCaseInput {}
