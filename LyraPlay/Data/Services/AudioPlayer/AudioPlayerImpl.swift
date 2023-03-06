//
//  AudioPlayerImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation
import Combine
import AVFoundation
import MediaPlayer


public final class AudioPlayerImpl: NSObject, AudioPlayer {

    // MARK: - Properties
    
    private let audioSession: AudioSession
    
    public var state: CurrentValueSubject<AudioPlayerState, Never> = .init(.initial)
    
    public var currentTime: TimeInterval {
        return currentStateController.currentTime
    }
    
    public var duration: TimeInterval {
        return currentStateController.duration
    }
    
    private lazy var currentStateController: AudioPlayerStateController = {
        
        InitialAudioPlayerStateController(delegate: self)
    } ()
    
    // MARK: - Initializers

    public init(
        audioSession: AudioSession
    ) {
        
        self.audioSession = audioSession
    }
    
    public func activateAudioSession() {
        audioSession.activate()
    }
    
    public func deactivateAudioSession() {
        audioSession.deactivate()
    }
    
    public func prepare(fileId: String, data: Data) -> Result<Void, AudioPlayerError> {
        return currentStateController.prepare(fileId: fileId, data: data)
    }
    
    public func resume() -> Result<Void, AudioPlayerError> {
        return currentStateController.resume()
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, AudioPlayerError> {
        
        return currentStateController.play(atTime: atTime)
    }
    
    public func playAndWaitForEnd() async -> Result<Void, AudioPlayerError> {
        
        
        do {
            
            for try await _ in playAndWaitForEnd() {}
            return .success(())
            
        } catch let error as AudioPlayerError {
            
            return .failure(error)
            
        } catch {
         
            return .failure(.internalError(error))
        }
    }
    
    public func playAndWaitForEnd() -> AsyncThrowingStream<AudioPlayerState, Error> {
        
        return AsyncThrowingStream { continuation in

            guard state.value.session != nil else {

                continuation.finish(throwing: AudioPlayerError.noActiveFile)
                return
            }
            
            let subscription = state.dropFirst()
                .sink { state in
                
                    switch state {
                        
                    case .finished:
                        continuation.yield(state)
                        continuation.finish()
                        return
                        
                    case .playing:
                        continuation.yield(state)
                        return
                        
                    default:
                        continuation.finish(throwing: AudioPlayerError.waitIsInterrupted)
                        return
                    }
                }
            
            continuation.onTermination = { _ in
                
                subscription.cancel()
            }

            let result = play(atTime: 0)
            
            guard case .success = result else {
                subscription.cancel()
                continuation.finish(throwing: result.error!)
                return
            }
        }
    }
    
    public func pause() -> Result<Void, AudioPlayerError> {
        return currentStateController.pause()
    }
    
    public func stop() -> Result<Void, AudioPlayerError> {
        return currentStateController.stop()
    }
    
    public func setTime(_ time: TimeInterval) {
        return currentStateController.setTime(time)
    }
}

extension AudioPlayerImpl: AudioPlayerStateControllerDelegate {
    
    public func load(fileId: String, data: Data) -> Result<Void, AudioPlayerError> {
        
        let controller = LoadingAudioPlayerStateController(
            fileId: fileId,
            data: data,
            delegate: self
        )
        
        return controller.runLoading()
    }
    
    public func didLoad(session: ActiveAudioPlayerStateControllerSession) {
        
        currentStateController = LoadedAudioPlayerStateController(
            session: session,
            delegate: self
        )

        state.value = .loaded(session: session.map())
    }
    
    public func stop(session: ActiveAudioPlayerStateControllerSession) -> Result<Void, AudioPlayerError> {
        
        let controller = StoppedAudioPlayerStateController(
            session: session.map(),
            delegate: self
        )

        return controller.runStopping(activeSession: session)
    }
    
    public func didStop(withController controller: StoppedAudioPlayerStateController) {
        
        deactivateAudioSession()
        currentStateController = controller
        state.value = .stopped
    }
    
    public func resumePlaying(session: ActiveAudioPlayerStateControllerSession) -> Result<Void, AudioPlayerError> {
        
        let controller = PlayingAudioPlayerStateController(
            session: session,
            delegate: self
        )
        
        activateAudioSession()
        return controller.runResumePlaying()
    }
    
    public func didResumePlaying(withController controller: PlayingAudioPlayerStateController) {
        
        currentStateController = controller
        
        state.value = .playing(session: controller.session.map())
    }
    
    public func pause(session: ActiveAudioPlayerStateControllerSession) -> Result<Void, AudioPlayerError> {
        
        let controller = PausedAudioPlayerStateController(
            session: session,
            delegate: self
        )
        
        return controller.runPausing()
    }
    
    public func didPause(withController controller: PausedAudioPlayerStateController) {
        
        deactivateAudioSession()
        currentStateController = controller
        
        state.value = .paused(session: controller.session.map(), time: 0)
    }
    
    public func startPlaying(atTime: TimeInterval, session: ActiveAudioPlayerStateControllerSession) -> Result<Void, AudioPlayerError> {
        
        let controller = PlayingAudioPlayerStateController(
            session: session,
            delegate: self
        )
        
        activateAudioSession()
        return controller.runPlaying(atTime: atTime)
    }
    
    public func didStartPlaying(withController controller: PlayingAudioPlayerStateController) {
        
        currentStateController = controller
        
        state.value = .playing(session: controller.session.map())
    }
    
    public func didFinishPlaying(session: ActiveAudioPlayerStateControllerSession) {
        
        deactivateAudioSession()
        currentStateController = FinishedAudioPlayerStateController(
            session: session,
            delegate: self
        )
        
        state.value = .finished(session: session.map())
    }
    
    public func seekPaused(atTime: TimeInterval, session: ActiveAudioPlayerStateControllerSession) {
        
        currentStateController = PausedAudioPlayerStateController(
            session: session,
            delegate: self
        )
    }
}

extension ActiveAudioPlayerStateControllerSession {
    
    func map() -> AudioPlayerSession {
        
        return .init(fileId: fileId)
    }
}
