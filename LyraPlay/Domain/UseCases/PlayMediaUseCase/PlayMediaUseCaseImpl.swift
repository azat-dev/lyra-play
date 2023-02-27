//
//  PlayMediaUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation
import Combine

public class PlayMediaUseCaseImpl: PlayMediaUseCase, PlayMediaUseCaseStateControllerDelegate {
    

    private struct CurrentState {
        
        let controller: PlayMediaUseCaseStateController
        let state: PlayMediaUseCaseState
    }
    
    // MARK: - Properties
    
    public lazy var state: CurrentValueSubject<PlayMediaUseCaseState, Never> = {
        
        .init(.initial)
    } ()
    
    private lazy var currentStateController: PlayMediaUseCaseStateController = {
        return InitialPlayMediaUseCaseStateController(delegate: self)
    } ()
    
    
    private var observers = Set<AnyCancellable>()
    
    private let loadTrackUseCaseFactory: LoadTrackUseCaseFactory
    private let audioPlayerFactory: AudioPlayerFactory
    
    // MARK: - Initializers
    
    public init(
        loadTrackUseCaseFactory: LoadTrackUseCaseFactory,
        audioPlayerFactory: AudioPlayerFactory
    ) {
        self.loadTrackUseCaseFactory = loadTrackUseCaseFactory
        self.audioPlayerFactory = audioPlayerFactory
    }
}

// MARK: - Methods

extension PlayMediaUseCaseImpl{
    
    public func prepare(mediaId: UUID) async -> Result<Void, PlayMediaUseCaseError> {
        
        return await currentStateController.prepare(mediaId: mediaId)
    }
    
    public func resume() -> Result<Void, PlayMediaUseCaseError> {
        
        return currentStateController.resume()
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaUseCaseError> {
        
        return currentStateController.play(atTime: atTime)
    }
    
    public func togglePlay() -> Result<Void, PlayMediaUseCaseError> {
        
        return currentStateController.togglePlay()
    }
    
    public func pause() -> Result<Void, PlayMediaUseCaseError> {
        
        return currentStateController.pause()
    }
    
    public func stop() -> Result<Void, PlayMediaUseCaseError> {
        
        return currentStateController.stop()
    }
}

// MARK: - Delegate

extension PlayMediaUseCaseImpl {
    
    public func load(mediaId: UUID) async -> Result<Void, PlayMediaUseCaseError> {

        state.value = .loading(mediaId: mediaId)
        
        let controller = LoadingPlayMediaUseCaseStateController(
            mediaId: mediaId,
            delegate: self,
            loadTrackUseCaseFactory: loadTrackUseCaseFactory,
            audioPlayerFactory: audioPlayerFactory
        )
        
        currentStateController = controller
        return await controller.load()
    }
    
    public func didLoad(
        mediaId: UUID,
        audioPlayer: AudioPlayer
    ) {
        
        let controller = LoadedPlayMediaUseCaseStateController(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )
        
        currentStateController = controller
        state.value = .loaded(mediaId: mediaId)
    }
    
    public func stop(
        mediaId: UUID,
        audioPlayer: AudioPlayer
    ) -> Result<Void, PlayMediaUseCaseError> {
        
        return currentStateController.stop()
    }
    
    public func didStop() {
        
        currentStateController = InitialPlayMediaUseCaseStateController(delegate: self)
        state.value = .stopped
    }
    
    public func didFailLoad(mediaId: UUID) {
        
        currentStateController = FailedLoadPlayMediaUseCaseStateController(
            mediaId: mediaId,
            delegate: self
        )
        
        state.value = .failedLoad(mediaId: mediaId)
    }
    
    public func didFinish(
        mediaId: UUID,
        audioPlayer: AudioPlayer
    ) {
        
        currentStateController = FinishedPlayMediaUseCaseStateController(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )
        
        state.value = .finished(mediaId: mediaId)
    }
    
    public func pause(
        mediaId: UUID,
        audioPlayer: AudioPlayer
    ) -> Result<Void, PlayMediaUseCaseError> {

        let result = audioPlayer.pause()
        
        guard case .success = result else {
            return .failure(.internalError(nil))
        }
        
        let controller = PausedPlayMediaUseCaseStateController(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )

        return controller.runPausing()
    }
    
    public func didPause(withController controller: PausedPlayMediaUseCaseStateController) {
        
        currentStateController = controller
        state.value = .paused(mediaId: controller.mediaId, time: 0)
    }
    
    public func play(
        atTime: TimeInterval,
        mediaId: UUID,
        audioPlayer: AudioPlayer
    ) -> Result<Void, PlayMediaUseCaseError> {
        
        let newController = PlayingPlayMediaUseCaseStateController(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )
        
        return newController.runPlaying(atTime: atTime)
    }
    
    public func didStartPlay(withController controller: PlayingPlayMediaUseCaseStateController) {
        
        currentStateController = controller
        state.value = .playing(mediaId: controller.mediaId)
    }
    
    public func resumePlaying(
        mediaId: UUID,
        audioPlayer: AudioPlayer
    ) -> Result<Void, PlayMediaUseCaseError> {
        
        let newController = PlayingPlayMediaUseCaseStateController(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: self
        )
        
        return newController.runResumePlaying()
    }
    
    public func didResumePlaying(withController controller: PlayingPlayMediaUseCaseStateController) {
        
        currentStateController = controller
        state.value = .playing(mediaId: controller.mediaId)
    }
}

// MARK: - Error Mapping

extension AudioPlayerError {
    
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

extension LoadTrackUseCaseError {
    
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

extension Result where Failure == AudioPlayerError  {
    
    func mapResult() -> Result<Success, PlayMediaUseCaseError> {
        
        guard case .success(let value) = self else {
            return .failure(self.error!.map())
        }
        
        return .success(value)
    }
}
