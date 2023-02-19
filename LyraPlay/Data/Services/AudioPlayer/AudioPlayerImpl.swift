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


public final class AudioPlayerImpl: NSObject, AudioPlayer, AudioPlayerStateControllerContext {

    // MARK: - Properties

    private let audioSession: AudioSession
    
    public var state: CurrentValueSubject<AudioPlayerState, Never> = .init(.initial)
    
    private lazy var currentStateController: AudioPlayerStateController = {
        
        InitialAudioPlayerStateController(context: self)
    } ()
    
    // MARK: - Initializers

    public init(audioSession: AudioSession) {
        
        self.audioSession = audioSession
    }
    
    public func setController(_ currenStateController: AudioPlayerStateController) {
        
        self.currentStateController = currenStateController
        state.value = currenStateController.currentState
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
    
    public func play() -> Result<Void, AudioPlayerError> {
        return currentStateController.play()
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, AudioPlayerError> {
        
        fatalError("Implement")
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

            let result = play()
            
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
}
