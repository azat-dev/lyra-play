//
//  CurrentPlayerStateUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 04.07.22.
//

import Foundation
import Combine

// MARK: - Interfaces

public enum CurrentPlayerStateUseCaseError: Error {
    
    case internalError(Error?)
}

public enum PlayerState: Equatable {
    
    case stopped
    case playing
    case paused
}

public protocol CurrentPlayerStateUseCaseOutput {
    
    var info: Observable<MediaInfo?> { get }
    
    var state: Observable<PlayerState> { get }
    
    var currentTime: Observable<Double> { get }
    
    var volume: Observable<Double> { get }
}

public protocol CurrentPlayerStateUseCaseInput {
}

public protocol CurrentPlayerStateUseCase: CurrentPlayerStateUseCaseOutput {
}

// MARK: - Implementations

public final class CurrentPlayerStateUseCaseImpl: CurrentPlayerStateUseCase {
    
    private let audioPlayer: AudioPlayerOutput
    private var audioPlayerCancellation: AnyCancellable?
    private let showMediaInfoUseCase: ShowMediaInfoUseCase
    
    private var prevTrackId: String?
    
    public var info: Observable<MediaInfo?> = Observable(nil)
    public var state: Observable<PlayerState> = Observable(.stopped)
    public var currentTime = Observable(0.0)
    public var volume = Observable(0.0)
    
    public init(
        audioPlayer: AudioPlayerOutput,
        showMediaInfoUseCase: ShowMediaInfoUseCase
    ) {
        
        self.audioPlayer = audioPlayer
        self.showMediaInfoUseCase = showMediaInfoUseCase
        
        bind(to: audioPlayer)
    }
    
    deinit {
        audioPlayerCancellation?.cancel()
    }
    
    private func updateTrackInfo(trackId: UUID) async {
        
        let result = await self.showMediaInfoUseCase.fetchInfo(trackId: trackId)
        
        guard let mediaInfo = try? result.get() else {
            
            self.state.value = .stopped
            self.info.value = nil
            return
        }
        
        self.info.value = mediaInfo
    }
    
    public func bind(to audioPlayer: AudioPlayerOutput) {
        
        audioPlayerCancellation = audioPlayer.state.sink { [weak self] state in

            guard let self = self else {
                return
            }
            
            var newOutputState = self.state.value
            var newTrackId = self.prevTrackId
            
            defer { self.prevTrackId = newTrackId }
            
            switch state {
            
            case .playing(let stateData):
                
                newOutputState = .playing
                newTrackId = stateData.fileId
                
            case .paused(let data, let time):
                
                newOutputState = .paused
                newTrackId = data.fileId
                self.currentTime.value = time
                
            case .stopped:
                
                newOutputState = .stopped
                self.currentTime.value = 0
                newTrackId = nil
                
            default:
                break
            }
            
            if newOutputState != self.state.value {
                self.state.value = newOutputState
                
                if newOutputState == .stopped {
                    self.info.value = nil
                    return
                }
            }
            
            if newTrackId != self.prevTrackId {
                
                guard
                    let newTrackId = newTrackId,
                    let trackId = UUID(uuidString: newTrackId)
                else {
                    
                    self.info.value = nil
                    return
                }
                
                Task {
                    await self.updateTrackInfo(trackId: trackId)
                }
            }
        }
    }
}

