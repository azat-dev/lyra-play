//
//  PlayMediaUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.08.2022.
//

import Foundation
import Combine

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
    case failedLoad(mediaId: UUID)
    case playing(mediaId: UUID)
    case stopped
    case interrupted(mediaId: UUID, time: TimeInterval)
    case paused(mediaId: UUID, time: TimeInterval)
    case finished(mediaId: UUID)
    
    public var mediaId: UUID? {
        
        switch self {
            
        case .initial, .stopped:
            return nil
            
        case .loading(let mediaId), .loaded(let mediaId), .playing(let mediaId), .interrupted(let mediaId, _), .paused(let mediaId, _), .finished(let mediaId), .failedLoad(let mediaId):
            return mediaId
        }
    }
}

public protocol PlayMediaUseCaseInput {
    
    func prepare(mediaId: UUID) async -> Result<Void, PlayMediaUseCaseError>
    
    func play() async -> Result<Void, PlayMediaUseCaseError>
    
    func play(atTime: TimeInterval) async -> Result<Void, PlayMediaUseCaseError>
    
    func pause() async -> Result<Void, PlayMediaUseCaseError>
    
    func stop() async -> Result<Void, PlayMediaUseCaseError>
}

public protocol PlayMediaUseCaseOutput {
    
    var state: CurrentValueSubject<PlayMediaUseCaseState, Never> { get }
}

public protocol PlayMediaUseCase: PlayMediaUseCaseOutput, PlayMediaUseCaseInput {
}

// MARK: - Implementations

public final class DefaultPlayMediaUseCase: PlayMediaUseCase {
    
    // MARK: - Properties
    
    private let audioService: AudioService
    private let loadTrackUseCase: LoadTrackUseCase
    
    public let state = CurrentValueSubject<PlayMediaUseCaseState, Never>(.initial)
    
    private var currentMediaId: UUID?
    
    private var observeAudioServiceCanellation: AnyCancellable?
    
    // MARK: - Initializers
    
    public init(
        audioService: AudioService,
        loadTrackUseCase: LoadTrackUseCase
    ) {
        
        self.audioService = audioService
        self.loadTrackUseCase = loadTrackUseCase
        
        observeAudioServiceCanellation = observe(audioService: audioService)
    }
    
    deinit {
        observeAudioServiceCanellation?.cancel()
    }
    
    private func observe(audioService: AudioService) -> AnyCancellable {
        
        return audioService.state.sink { [weak self] audioServiceState in
            
            guard
                let self = self,
                let currentMediaId = self.state.value.mediaId
            else {
                return
            }
            
            guard currentMediaId.uuidString == audioServiceState.session?.fileId else {
                self.state.value = .stopped
                return
            }
            
            switch audioServiceState {
                
            case .initial:
                break
                
            case .loaded:
                self.state.value = .loaded(mediaId: currentMediaId)
                
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
    
    public func prepare(mediaId: UUID) async -> Result<Void, PlayMediaUseCaseError> {
        
        state.value = .loading(mediaId: mediaId)
        let loadResult = await loadTrackUseCase.load(trackId: mediaId)
        
        guard case .success(let trackData) = loadResult else {
            
            state.value = .failedLoad(mediaId: mediaId)
            return .failure(map(error: loadResult.error!))
        }
        
        let prepareResult = await audioService.prepare(fileId: mediaId.uuidString, data: trackData)
        
        guard case .success = prepareResult else {
            
            state.value = .failedLoad(mediaId: mediaId)
            return .failure(map(error: loadResult.error!))
        }
        
        state.value = .loaded(mediaId: mediaId)
        return .success(())
    }
    
    private func play(at time: TimeInterval?) async -> Result<Void, PlayMediaUseCaseError> {

        guard case .loaded = self.state.value else {
            return .failure(.noActiveTrack)
        }
        
        let playResult: Result<Void, AudioServiceError>
        
        if let time = time {
            playResult = await audioService.play(atTime: time)
        } else {
            playResult = await audioService.play()
        }
        
        guard case .success = playResult else {
            return .failure(map(error: playResult.error!))
        }
        
        return .success(())
    }
    
    public func play() async -> Result<Void, PlayMediaUseCaseError> {
        
        switch self.state.value {
            
        case .interrupted, .paused, .loaded:
            return await play(at: nil)
            
        default:
            return .failure(.noActiveTrack)
        }
    }
    
    public func play(atTime: TimeInterval) async -> Result<Void, PlayMediaUseCaseError> {
        
        return await play(at: atTime)
    }
    
    public func pause() async -> Result<Void, PlayMediaUseCaseError> {
        
        let pauseResult = await audioService.pause()
        
        guard case .success = pauseResult else {
            return .failure(map(error: pauseResult.error!))
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
