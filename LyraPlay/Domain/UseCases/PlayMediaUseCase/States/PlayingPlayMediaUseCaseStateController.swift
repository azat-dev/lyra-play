//
//  PlayingPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation
import Combine

public class PlayingPlayMediaUseCaseStateController: PlayMediaUseCaseStateController {

    // MARK: - Properties
    
    public let mediaId: UUID
    public let audioPlayer: AudioPlayer
    public weak var delegate: PlayMediaUseCaseStateControllerDelegate?
    
    public var currentTime: TimeInterval {
        return audioPlayer.currentTime
    }
    
    public var duration: TimeInterval {
        return audioPlayer.duration
    }
    
    private let updatePlayedTimeUseCaseFactory: UpdatePlayedTimeUseCaseFactory
    private var timer: DispatchSourceTimer?
    
    private var observers = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    public init(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        delegate: PlayMediaUseCaseStateControllerDelegate,
        updatePlayedTimeUseCaseFactory: UpdatePlayedTimeUseCaseFactory
    ) {
        
        self.updatePlayedTimeUseCaseFactory = updatePlayedTimeUseCaseFactory
        
        self.mediaId = mediaId
        self.audioPlayer = audioPlayer
        self.delegate = delegate
        
        audioPlayer.state.sink { [weak self] state in
        
            guard let self = self else {
                return
            }
            
            guard case .finished = state else {
                return
            }
            
            self.updatePlayedTime()
            
            delegate.didFinish(
                mediaId: self.mediaId,
                audioPlayer: self.audioPlayer
            )
            
            
        }.store(in: &observers)
    }
    
    deinit {
        timer?.cancel()
        timer = nil
    }
    
    // MARK: - Methods
    
    public func prepare(mediaId: UUID) async -> Result<Void, PlayMediaUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        stopUpdatingPlayedTime()
        updatePlayedTime()
        
        return await delegate.load(mediaId: mediaId)
    }
    
    public func resume() -> Result<Void, PlayMediaUseCaseError> {
        
        return .success(())
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.play(
            atTime: atTime,
            mediaId: mediaId,
            audioPlayer: audioPlayer
        )
    }
    
    public func pause() -> Result<Void, PlayMediaUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        stopUpdatingPlayedTime()
        updatePlayedTime()
        
        return delegate.pause(
            mediaId: mediaId,
            audioPlayer: audioPlayer
        )
    }
    
    public func togglePlay() -> Result<Void, PlayMediaUseCaseError> {
        return pause()
    }
    
    private func updatePlayedTime() {
        
        Task {
            let updatePlayedTimeUseCase = updatePlayedTimeUseCaseFactory.make()
            
            let _ = await updatePlayedTimeUseCase.updatePlayedTime(
                for: mediaId,
                time: audioPlayer.currentTime
            )
        }
    }
    
    private func stopUpdatingPlayedTime() {
        timer?.cancel()
        timer = nil
    }
    
    public func stop() -> Result<Void, PlayMediaUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        stopUpdatingPlayedTime()
        updatePlayedTime()
        
        return delegate.stop(
            mediaId: mediaId,
            audioPlayer: audioPlayer
        )
    }
    
    private func startUpdatingPlayedTime() {
        
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        self.timer = timer
        
        timer.schedule(deadline: .now(), repeating: .seconds(1))
        
        timer.setEventHandler { [weak self] in
            self?.updatePlayedTime()
        }
        timer.resume()
    }
    
    public func runResumePlaying() -> Result<Void, PlayMediaUseCaseError> {
        
        let result = audioPlayer.resume()
        
        guard case .success = result else {
            return result.mapResult()
        }
        
        startUpdatingPlayedTime()
        delegate?.didResumePlaying(withController: self)
        return .success(())
    }
    
    public func runPlaying(atTime: TimeInterval) -> Result<Void, PlayMediaUseCaseError> {
        
        let result = audioPlayer.play(atTime: atTime)
        
        guard case .success = result else {
            return result.mapResult()
        }
        
        startUpdatingPlayedTime()
        delegate?.didStartPlay(withController: self)
        return .success(())
    }
}
