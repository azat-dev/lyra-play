//
//  PlayMediaUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.08.2022.
//

import Foundation

// MARK: - Interfaces

public enum PlayMediaUseCaseError: Error {
    
    case trackNotFound
    case noActiveTrack
    case internalError(Error?)
}

public enum PlayMediaUseCaseState: Equatable {
    
    case initial
    case loading(mediaId: UUID)
    case loaded(mediaId: UUID)
    case playing(mediaId: UUID)
    case stopped
    case interrupted(mediaId: UUID, time: TimeInterval)
    case paused(mediaId: UUID, time: TimeInterval)
    case finished(mediaId: UUID)
    
    func getMediaId() -> UUID? {
        
        switch self {

        case .initial, .stopped:
            return nil

        case .loading(let mediaId), .loaded(let mediaId), .playing(let mediaId), .interrupted(let mediaId, _), .paused(let mediaId, _), .finished(let mediaId):
            return mediaId
        }
    }
}

public protocol PlayMediaUseCaseInput {
    
    func play(mediaId: UUID) async -> Result<Void, PlayMediaUseCaseError>
    
    func pause() async -> Result<Void, PlayMediaUseCaseError>
    
    func stop() async -> Result<Void, PlayMediaUseCaseError>
}

public protocol PlayMediaUseCaseOutput {
    
    var state: Observable<PlayMediaUseCaseState> { get }
}

public protocol PlayMediaUseCase: PlayMediaUseCaseOutput, PlayMediaUseCaseInput {
}

// MARK: - Implementations

public final class DefaultPlayMediaUseCase: PlayMediaUseCase {
    
    // MARK: - Properties
    
    private let audioService: AudioService
    private let loadTrackUseCase: LoadTrackUseCase
    
    public let state: Observable<PlayMediaUseCaseState> = .init(.initial)
    
    private var currentMediaId: UUID?
    
    // MARK: - Initializers
    
    public init(
        audioService: AudioService,
        loadTrackUseCase: LoadTrackUseCase
    ) {
        
        self.audioService = audioService
        self.loadTrackUseCase = loadTrackUseCase
        
        observeAudioService()
    }
    
    private func observeAudioService() {
        
        self.audioService.state.observeIgnoreInitial(on: self) { [weak self] audioServiceState in
            
            guard
                let self = self,
                let currentMediaId = self.state.value.getMediaId()
            else {
                return
            }
            
            guard currentMediaId.uuidString == audioServiceState.getFileId() else {
                
                self.state.value = .stopped
                return
            }

            switch audioServiceState {
                
            case .initial:
                break
                
            case .stopped:
                self.state.value = .stopped
                
            case .playing:
                self.state.value = .playing(mediaId: currentMediaId)
            
            case .interrupted(_, let time):
                self.state.value = .interrupted(mediaId: currentMediaId, time: time)
                
            case .paused(_, let time):
                self.state.value = .paused(mediaId: currentMediaId, time: time)
                
            case .finished:
                self.state.value = .finished(mediaId: currentMediaId)
            }
        }
    }
}

// MARK: - Input methods

extension DefaultPlayMediaUseCase {
    
    public func play(mediaId: UUID) async -> Result<Void, PlayMediaUseCaseError> {
        
        self.state.value = .loading(mediaId: mediaId)
        let loadResult = await loadTrackUseCase.load(trackId: mediaId)
        
        guard case .success(let trackData) = loadResult else {

            self.state.value = .initial
            let mappedError = map(error: loadResult.error!)
            return .failure(mappedError)
        }
        
        self.state.value = .loaded(mediaId: mediaId)
        
        let playResult = await audioService.play(fileId: mediaId.uuidString, data: trackData)
        
        guard case .success = playResult else {
            
            self.state.value = .initial
            let mappedError = map(error: playResult.error!)
            return .failure(mappedError)
        }
        
        return .success(())
    }
    
    public func pause() async -> Result<Void, PlayMediaUseCaseError> {
        
        let pauseResult = await audioService.pause()
        
        guard case .success = pauseResult else {
            let mappedError = map(error: pauseResult.error!)
            return .failure(mappedError)
        }
        
        return .success(())
    }
    
    public func stop() async -> Result<Void, PlayMediaUseCaseError> {
        
        fatalError("Not implemented")
    }
}
// MARK: - Error Mappings

extension DefaultPlayMediaUseCase {
    
    private func map(error: AudioServiceError) -> PlayMediaUseCaseError {
        
        switch error {
            
        case .internalError(let err):
            return .internalError(err)
            
        case .noActiveFile:
            return .noActiveTrack
            
        case .waitIsInterrupted:
            return .internalError(nil)
        }
    }
    
    private func map(error: LoadTrackUseCaseError) -> PlayMediaUseCaseError {
        
        switch error {
        case .trackNotFound:
            return .trackNotFound
        case .internalError(let err):
            return .internalError(err)
        }
    }
}
