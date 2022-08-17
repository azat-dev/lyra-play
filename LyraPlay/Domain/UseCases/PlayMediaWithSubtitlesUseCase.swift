//
//  PlayMediaWithSubtitlesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.08.2022.
//

import Foundation
import Combine

// MARK: - Interfaces

public enum PlayMediaWithSubtitlesUseCaseError: Error {
    
    case mediaFileNotFound
    case internalError(Error?)
    case noActiveMedia
}

public enum PlayMediaWithSubtitlesUseCaseState: Equatable {
    
    case initial
    case loading(session: PlayMediaWithSubtitlesSessionParams)
    case loadFailed(session: PlayMediaWithSubtitlesSessionParams)
    case loaded(session: PlayMediaWithSubtitlesSessionParams, subtitlesState: SubtitlesState?)
    case playing(session: PlayMediaWithSubtitlesSessionParams, subtitlesState: SubtitlesState?)
    case paused(session: PlayMediaWithSubtitlesSessionParams, subtitlesState: SubtitlesState?, time: TimeInterval)
    case stopped(session: PlayMediaWithSubtitlesSessionParams)
    case finished(session: PlayMediaWithSubtitlesSessionParams)
}

extension PlayMediaWithSubtitlesUseCaseState {
    
    var session: PlayMediaWithSubtitlesSessionParams? {
        
        switch self {
            
        case .initial:
            return nil
            
        case .loading(let session), .loadFailed(let session),
                .loaded(let session, _), .playing(let session, _),
                .paused(let session, _, _), .finished(let session), .stopped(let session):
            
            return session
        }
    }
    
    var subtitlesState: SubtitlesState? {
        
        switch self {
            
        case .initial, .loading, .loadFailed, .stopped, .finished:
            return nil
            
        case .loaded(_, let subtitlesState), .playing(_, let subtitlesState), .paused(_, let subtitlesState, _):
            
            return subtitlesState
        }
    }
}

public struct SubtitlesState: Equatable {
    
    public var position: SubtitlesPosition?
    public var subtitles: Subtitles
    
    public init(
        position: SubtitlesPosition?,
        subtitles: Subtitles
    ) {
        
        self.position = position
        self.subtitles = subtitles
    }
    
    public func positioned(_ position: SubtitlesPosition) -> SubtitlesState {
        
        var newState = self
        newState.position = position
        return newState
    }
}

public struct PlayMediaWithSubtitlesSessionParams: Equatable {
    
    public var mediaId: UUID
    public var subtitlesLanguage: String
    
    public init(
        mediaId: UUID,
        subtitlesLanguage: String
    ) {
        
        self.mediaId = mediaId
        self.subtitlesLanguage = subtitlesLanguage
    }
}
public protocol PlayMediaWithSubtitlesUseCaseInput: AnyObject {
    
    func prepare(params: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func play() -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func pause() -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func stop() -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
}

public protocol PlayMediaWithSubtitlesUseCaseOutput: AnyObject {
    
    var state: CurrentValueSubject<PlayMediaWithSubtitlesUseCaseState, Never> { get }
    
    var willChangeSubtitlesPosition: PassthroughSubject<WillChangeSubtitlesPositionData, Never> { get }
}

public protocol PlayMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCaseOutput, PlayMediaWithSubtitlesUseCaseInput {
}

// MARK: - Implementations

public final class DefaultPlayMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCase {
    
    // MARK: - Properties
    
    private let playMediaUseCase: PlayMediaUseCase
    private let playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory
    private let loadSubtitlesUseCase: LoadSubtitlesUseCase
    
    public let state: CurrentValueSubject<PlayMediaWithSubtitlesUseCaseState, Never> = .init(.initial)
    public let willChangeSubtitlesPosition =  PassthroughSubject<WillChangeSubtitlesPositionData, Never>()
    
    private var playSubtitlesObserver: AnyCancellable?
    private var subtitlesChangesObserver: AnyCancellable?
    private var playMediaObserver: AnyCancellable?
    
    private var playSubtitlesUseCase: PlaySubtitlesUseCase? {
        
        didSet {
            
            playSubtitlesObserver?.cancel()
            subtitlesChangesObserver?.cancel()
            
            subtitlesChangesObserver = playSubtitlesUseCase?.willChangePosition.sink { [weak self] in
                self?.willChangeSubtitlesPosition.send($0)
            }
            
            playSubtitlesObserver = playSubtitlesUseCase?.state.sink { [weak self] in self?.updateSubtitlesPosition($0) }
        }
    }
    
    // MARK: - Initializers
    
    public init(
        playMediaUseCase: PlayMediaUseCase,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        loadSubtitlesUseCase: LoadSubtitlesUseCase
    ) {
        
        self.playMediaUseCase = playMediaUseCase
        self.playSubtitlesUseCaseFactory = playSubtitlesUseCaseFactory
        self.loadSubtitlesUseCase = loadSubtitlesUseCase
        
        playMediaObserver = playMediaUseCase.state.sink { [weak self] in
            
            self?.updateStateOnMediaChange($0)
            self?.syncSubtitlesPlayingWithMedia($0)
        }
    }
    
    deinit {
        playSubtitlesObserver?.cancel()
        playMediaObserver?.cancel()
        subtitlesChangesObserver?.cancel()
    }
}

// MARK: - Input methods

extension DefaultPlayMediaWithSubtitlesUseCase {
    
    public func prepare(params session: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        state.value = .loading(session: session)
        
        let loadMediaResult = await playMediaUseCase.prepare(mediaId: session.mediaId)
        
        guard case .success = loadMediaResult else {
            
            state.value = .loadFailed(session: session)
            return loadMediaResult.mapResult()
        }
        
        let loadSubtitlesResult = await loadSubtitlesUseCase.load(
            for: session.mediaId,
            language: session.subtitlesLanguage
        )
        
        guard case .success(let subtitles) = loadSubtitlesResult else {
            
            state.value = .loaded(session: session, subtitlesState: nil)
            return .success(())
        }
        
        playSubtitlesUseCase = playSubtitlesUseCaseFactory.create(with: subtitles)
        
        self.state.value = .loaded(
            session: session,
            subtitlesState: .init(
                position: nil,
                subtitles: subtitles
            )
        )
        
        return .success(())
    }
    
    public func play() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        switch state.value {
            
        case .initial, .loading, .loadFailed:
            return .failure(.noActiveMedia)
            
        default:
            break
        }
        
        return playMediaUseCase.play().mapResult()
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        switch state.value {
            
        case .initial, .loading, .loadFailed:
            return .failure(.noActiveMedia)
            
        default:
            return playMediaUseCase.play(atTime: atTime).mapResult()
        }
    }
    
    public func pause() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        guard case .playing = state.value else {
            return .failure(.noActiveMedia)
        }
        
        return playMediaUseCase.pause().mapResult()
    }
    
    private func releaseResources() {
        
        playSubtitlesUseCase?.stop()
        playSubtitlesUseCase = nil
    }
    
    private func stopLoading() {
        
        releaseResources()
    }
    
    public func stop() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        switch state.value {
            
        case .initial, .stopped, .loadFailed:
            break
            
        case .loading:
            stopLoading()
            
        case .loaded:
            releaseResources()
            
        case .playing, .paused, .finished:
            
            return playMediaUseCase.stop().mapResult()
        }
        
        return .success(())
    }
}

// MARK: - Helpers


extension DefaultPlayMediaWithSubtitlesUseCase {
    
    private func updateSubtitlesPosition(_ subtitlesState: PlaySubtitlesUseCaseState) {
        
        let currentState = state.value
        
        guard let currentSubtitlesState = currentState.subtitlesState else {
            return
        }
        
        guard case .playing(let position) = subtitlesState else {
            return
        }
        
        var newSubtitlesState = currentSubtitlesState
        newSubtitlesState.position = position
        
        switch currentState {
            
        case .playing(let session, _):
            state.value = .playing(session: session, subtitlesState: newSubtitlesState)
            
        case .paused(let session, _, let time):
            state.value = .paused(session: session, subtitlesState: newSubtitlesState, time: time)
            
        case .initial, .stopped, .finished, .loading, .loaded, .loadFailed:
            return
        }
    }
    
    private func updateStateOnMediaChange(_ mediaState: PlayMediaUseCaseState) {
        
        let currentState = state.value
        guard let session = currentState.session else {
            return
        }
        
        switch mediaState {
            
        case .initial, .loading, .loaded, .failedLoad:
            break
            
        case .stopped:
            releaseResources()
            state.value = .stopped(session: session)
            
        case .playing:
            state.value = .playing(session: session, subtitlesState: currentState.subtitlesState)
            
        case .paused(_, let time):
            state.value = .paused(session: session, subtitlesState: currentState.subtitlesState, time: time)
            
        case .finished:
            state.value = .finished(session: session)
        }
    }
    
    private func syncSubtitlesPlayingWithMedia(_ newState: PlayMediaUseCaseState) {
        
        switch newState {
            
        case .initial, .loading, .loaded, .failedLoad:
            break
            
        case .playing:
            playSubtitlesUseCase?.play()
            
        case .stopped, .finished:
            playSubtitlesUseCase?.stop()
            
        case .paused:
            playSubtitlesUseCase?.pause()
        }
    }
}

// MARK: - Error Mapping

fileprivate extension PlayMediaUseCaseError {
    
    func map() -> PlayMediaWithSubtitlesUseCaseError {
        
        switch self {
            
        case .noActiveTrack:
            return .noActiveMedia
            
        case .trackNotFound:
            return .mediaFileNotFound
            
        case .internalError(let error):
            return .internalError(error)
        }
    }
}

// MARK: - Result Mapping

fileprivate extension Result where Failure == PlayMediaUseCaseError  {
    
    func mapResult() -> Result<Success, PlayMediaWithSubtitlesUseCaseError> {
        
        guard case .success(let value) = self else {
            return .failure(self.error!.map())
        }
        
        return .success(value)
    }
}
