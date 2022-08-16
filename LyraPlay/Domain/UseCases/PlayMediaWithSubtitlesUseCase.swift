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
    case interrupted(session: PlayMediaWithSubtitlesSessionParams, subtitlesState: SubtitlesState?, time: TimeInterval)
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
                .loaded(let session, _), .playing(let session, _), .interrupted(let session, _, _),
                .paused(let session, _, _), .finished(let session), .stopped(let session):
            
            return session
        }
    }
    
    var subtitlesState: SubtitlesState? {
        
        switch self {
            
        case .initial, .loading, .loadFailed, .stopped, .finished:
            return nil
            
        case .loaded(_, let subtitlesState), .playing(_, let subtitlesState), .interrupted(_, let subtitlesState, _), .paused(_, let subtitlesState, _):
            
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
    
    func play() async -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func play(atTime: TimeInterval) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func pause() async -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func stop() async -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
}

public protocol PlayMediaWithSubtitlesUseCaseOutput: AnyObject {
    
    var state: CurrentValueSubject<PlayMediaWithSubtitlesUseCaseState, Never> { get }
}

public protocol PlayMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCaseOutput, PlayMediaWithSubtitlesUseCaseInput {
}

// MARK: - Implementations

public final class DefaultPlayMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCase {
    
    // MARK: - Properties
    
    private let playMediaUseCase: PlayMediaUseCase
    private let playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory
    private let loadSubtitlesUseCase: LoadSubtitlesUseCase
    
    public var state: CurrentValueSubject<PlayMediaWithSubtitlesUseCaseState, Never> = .init(.initial)
    
    private var playSubtitlesObserver: AnyCancellable?
    private var playMediaObserver: AnyCancellable?
    
    private var playSubtitlesUseCase: PlaySubtitlesUseCase? {
        
        didSet {
            playSubtitlesObserver?.cancel()
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
    }
}

// MARK: - Input methods

extension DefaultPlayMediaWithSubtitlesUseCase {
    
    public func prepare(params session: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        state.value = .loading(session: session)
        
        let loadMediaResult = await playMediaUseCase.prepare(mediaId: session.mediaId)
        
        guard case .success = loadMediaResult else {
            
            state.value = .loadFailed(session: session)
            return .failure(map(error: loadMediaResult.error!))
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
    
    public func play() async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        switch state.value {
            
        case .initial, .loading, .loadFailed:
            return .failure(.noActiveMedia)
            
        default:
            break
        }
        
        return map(result: await playMediaUseCase.play())
    }
    
    public func play(atTime: TimeInterval) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        
        switch state.value {
            
        case .initial, .loading, .loadFailed:
            return .failure(.noActiveMedia)
            
        default:
            return map(result: await playMediaUseCase.play(atTime: atTime))
        }
    }
    
    public func pause() async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        guard case .playing = state.value else {
            return .failure(.noActiveMedia)
        }
        
        return map(result: await playMediaUseCase.pause())
    }
    
    private func releaseResources() {
        
        playSubtitlesUseCase?.stop()
        playSubtitlesUseCase = nil
    }
    
    private func stopLoading() {
        
        releaseResources()
    }
    
    public func stop() async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        switch state.value {
            
        case .initial, .stopped, .loadFailed:
            break
            
        case .loading:
            stopLoading()
            
        case .loaded:
            releaseResources()
            
        case .playing, .interrupted, .paused, .finished:
            
            let result = await playMediaUseCase.stop()
            return map(result: result)
        }
        
        return .success(())
    }
    
    private func map(result: Result<Void, PlayMediaUseCaseError>) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        guard case .success = result else {
            return .failure(map(error: result.error!))
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
            
        case .interrupted(let session, _, let time):
            state.value = .interrupted(session: session, subtitlesState: newSubtitlesState, time: time)
            
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
            
        case .interrupted(_, let time):
            state.value = .interrupted(
                session: session,
                subtitlesState: currentState.subtitlesState,
                time: time
            )
            
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
            
        case .paused, .interrupted:
            playSubtitlesUseCase?.pause()
        }
    }
}

// MARK: - Error Mappings

extension DefaultPlayMediaWithSubtitlesUseCase {
    
    private func map(error: PlayMediaUseCaseError) -> PlayMediaWithSubtitlesUseCaseError {
        
        switch error {
            
        case .noActiveTrack:
            return .noActiveMedia
            
        case .trackNotFound:
            return .mediaFileNotFound
            
        case .internalError(let error):
            return .internalError(error)
        }
    }
}
