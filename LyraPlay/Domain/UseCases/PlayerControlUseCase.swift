//
//  PlayerControlUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation
import UIKit

// MARK: - Interfaces

public enum PlayerControlUseCaseError: Error {
    
    case trackNotFound
    case internalError(Error?)
}

public protocol PlayerControlUseCaseOutput {
    
}

public protocol PlayerControlUseCaseInput {
    
    func play(trackId: UUID) async -> Result<Void, PlayerControlUseCaseError>
}

public protocol PlayerControlUseCase: PlayerControlUseCaseInput, PlayerControlUseCaseOutput {
    
}

// MARK: - Implementations

public final class DefaulPlayerControlUseCase: PlayerControlUseCase {
    
    
    private let audioService: AudioServiceInput
    private let loadTrackUseCase: LoadTrackUseCase
    
    public init(
        audioService: AudioServiceInput,
        loadTrackUseCase: LoadTrackUseCase
    ) {
        
        self.audioService = audioService
        self.loadTrackUseCase = loadTrackUseCase
    }
    
    private func mapLoadTrackError(_ error: LoadTrackUseCaseError) -> PlayerControlUseCaseError {
        
        switch error {
        case .trackNotFound:
            return .trackNotFound
        case .internalError(let err):
            return .internalError(err)
        }
    }
    
    private func mapAudioServiceError(_ error: AudioServiceError) -> PlayerControlUseCaseError {
        
        switch error {
        case .internalError(let err):
            return .internalError(err)
        }
    }
    
    public func play(trackId: UUID) async -> Result<Void, PlayerControlUseCaseError> {
        
        let loadResult = await loadTrackUseCase.load(trackId: trackId)
        
        guard case .success(let trackData) = loadResult else {
            let mappedError = mapLoadTrackError(loadResult.error!)
            return .failure(mappedError)
        }
        
        let playResult = await audioService.play(fileId: trackId.uuidString, data: trackData)
        
        guard case .success = playResult else {
            let mappedError = mapAudioServiceError(playResult.error!)
            return .failure(mappedError)
        }
        
        return .success(())
    }
}
