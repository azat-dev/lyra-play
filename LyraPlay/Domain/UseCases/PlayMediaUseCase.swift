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
    case paused(mediaId: UUID, time: TimeInterval)
    case finished(mediaId: UUID)
    
    public var mediaId: UUID? {
        
        switch self {
            
        case .initial, .stopped:
            return nil
            
        case .loading(let mediaId), .loaded(let mediaId), .playing(let mediaId), .paused(let mediaId, _), .finished(let mediaId), .failedLoad(let mediaId):
            return mediaId
        }
    }
}

public protocol PlayMediaUseCaseInput {
    
    func prepare(mediaId: UUID) async -> Result<Void, PlayMediaUseCaseError>
    
    func play() -> Result<Void, PlayMediaUseCaseError>
    
    func play(atTime: TimeInterval) -> Result<Void, PlayMediaUseCaseError>
    
    func pause() -> Result<Void, PlayMediaUseCaseError>
    
    func stop() -> Result<Void, PlayMediaUseCaseError>
}

public protocol PlayMediaUseCaseOutput {
    
    var state: CurrentValueSubject<PlayMediaUseCaseState, Never> { get }
}

public protocol PlayMediaUseCase: PlayMediaUseCaseOutput, PlayMediaUseCaseInput {
}

// MARK: - Implementations

public final class DefaultPlayMediaUseCase: PlayMediaUseCase {
    
    // MARK: - Properties
    
    private let audioPlayer: AudioPlayer
    private let loadTrackUseCase: LoadTrackUseCase
    
    public let state = CurrentValueSubject<PlayMediaUseCaseState, Never>(.initial)
    
    private var currentMediaId: UUID?
    
    private var observeAudioPlayerCanellation: AnyCancellable?
    
    // MARK: - Initializers
    
    public init(
        audioPlayer: AudioPlayer,
        loadTrackUseCase: LoadTrackUseCase
    ) {
        
        self.audioPlayer = audioPlayer
        self.loadTrackUseCase = loadTrackUseCase
        
        observeAudioPlayerCanellation = observe(audioPlayer: audioPlayer)
    }
    
    deinit {
        observeAudioPlayerCanellation?.cancel()
    }
    
    private func observe(audioPlayer: AudioPlayer) -> AnyCancellable {
        
        return audioPlayer.state.sink { [weak self] audioPlayerState in
            
            guard
                let self = self,
                let currentMediaId = self.state.value.mediaId
            else {
                return
            }
            
            guard currentMediaId.uuidString == audioPlayerState.session?.fileId else {
                self.state.value = .stopped
                return
            }
            
            switch audioPlayerState {
                
            case .initial, .loaded:
                break
                
            case .stopped:
                self.state.value = .stopped
                
            case .playing:
                self.state.value = .playing(mediaId: currentMediaId)
                
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
            return .failure(loadResult.error!.map())
        }
        
        let prepareResult = audioPlayer.prepare(fileId: mediaId.uuidString, data: trackData)
        
        guard case .success = prepareResult else {
            
            state.value = .failedLoad(mediaId: mediaId)
            return .failure(loadResult.error!.map())
        }
        
        state.value = .loaded(mediaId: mediaId)
        return .success(())
    }
    
    private func play(at time: TimeInterval?) -> Result<Void, PlayMediaUseCaseError> {

        guard state.value.mediaId != nil else {
            return .failure(.noActiveTrack)
        }
        
        if let time = time {
            return audioPlayer.play(atTime: time).mapResult()
        }
        
        return audioPlayer.play().mapResult()
    }
    
    public func play() -> Result<Void, PlayMediaUseCaseError> {
        
        switch self.state.value {
            
        case .paused, .loaded:
            return play(at: nil)
            
        default:
            return .failure(.noActiveTrack)
        }
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaUseCaseError> {
        
        return play(at: atTime)
    }
    
    public func pause() -> Result<Void, PlayMediaUseCaseError> {
        
        return audioPlayer.pause().mapResult()
    }
    
    public func stop() -> Result<Void, PlayMediaUseCaseError> {
        
        return audioPlayer.stop().mapResult()
    }
}

// MARK: - Error Mapping

fileprivate extension AudioPlayerError {
    
    func map() -> PlayMediaUseCaseError {
        
        switch self {
            
        case .internalError(let err):
            return .internalError(err)
            
        case .noActiveFile:
            return .noActiveTrack
            
        case .waitIsInterrupted:
            return .internalError(nil)
        }
    }
}

fileprivate extension LoadTrackUseCaseError {
    
    func map() -> PlayMediaUseCaseError {
        
        switch self {
            
        case .trackNotFound:
            return .trackNotFound
            
        case .internalError(let err):
            return .internalError(err)
        }
    }
}

// MARK: - Result Mapping

fileprivate extension Result where Failure == AudioPlayerError  {
    
    func mapResult() -> Result<Success, PlayMediaUseCaseError> {
        
        guard case .success(let value) = self else {
            return .failure(self.error!.map())
        }
        
        return .success(value)
    }
}
