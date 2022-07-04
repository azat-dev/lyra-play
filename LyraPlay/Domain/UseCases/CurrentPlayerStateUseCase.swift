//
//  CurrentPlayerStateUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 04.07.22.
//

import Foundation

// MARK: - Interfaces

public enum CurrentPlayerStateUseCaseError: Error {
    
    case internalError(Error?)
}

public enum PlayerState {
    
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

public final class DefaultCurrentPlayerStateUseCase: CurrentPlayerStateUseCase {
    
    private let audioService: AudioServiceOutput
    private let showMediaInfoUseCase: ShowMediaInfoUseCase
    
    public var info: Observable<MediaInfo?> = Observable(nil)
    public var state: Observable<PlayerState> = Observable(.stopped)
    public var currentTime = Observable(0.0)
    public var volume = Observable(0.0)
    
    public init(
        audioService: AudioServiceOutput,
        showMediaInfoUseCase: ShowMediaInfoUseCase
    ) {

        self.audioService = audioService
        self.showMediaInfoUseCase = showMediaInfoUseCase

        bind(to: audioService)
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

    public func bind(to audioService: AudioServiceOutput) {
    
        audioService.fileId.observe(on: self) { [weak self] persistentTrackId in
            
            guard let self = self else {
                return
            }
            
            guard
                let persistentTrackId = persistentTrackId,
                let trackId = UUID(uuidString: persistentTrackId)
            else {

                let newStateValue = PlayerState.stopped
                let isStateChanged = self.state.value != newStateValue
                
                if isStateChanged {
                    self.state.value = newStateValue
                    self.info.value = nil
                }
                return
            }
            
            Task {
                await self.updateTrackInfo(trackId: trackId)
            }
        }
        
        audioService.isPlaying.observe(on: self) { [weak self] isPlaying in
            
            guard let self = self else {
                return
            }
            
            guard !isPlaying else {
                self.state.value = .playing
                return
            }
            
            let prevState = self.state.value

            if prevState == .playing {
                self.state.value = .paused
            }
        }
        
        audioService.currentTime.observe(on: self) { [weak self] currentTime in
            
            self?.currentTime.value = currentTime
        }
        
        audioService.volume.observe(on: self) { [weak self] volume in
            
            self?.volume.value = volume
        }
    }
}

