//
//  PlayMediaWithSubtitlesUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation
import Combine

public final class PlayMediaWithSubtitlesUseCaseImpl: PlayMediaWithSubtitlesUseCase {

    // MARK: - Properties

    private let playMediaUseCase: PlayMediaUseCase
    private let playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory
    private let loadSubtitlesUseCase: LoadSubtitlesUseCase
    
    public var state: CurrentValueSubject<PlayMediaWithSubtitlesUseCaseState, Never> = .init(.initial)
    public var willChangeSubtitlesPosition = PassthroughSubject<WillChangeSubtitlesPositionData, Never>()
    
    private var playSubtitlesObserver: AnyCancellable?
    private var subtitlesChangesObserver: AnyCancellable?
    private var playMediaObserver: AnyCancellable?
    
    private var stateHash = UUID()
    
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
        }
    }
    
    deinit {
        playSubtitlesObserver?.cancel()
        playMediaObserver?.cancel()
        subtitlesChangesObserver?.cancel()
    }
    
    private func isStateUpdated(hash: UUID) -> Bool {
        return hash != stateHash
    }
    
    private func updateStateHash() {
        stateHash = UUID()
    }
    
    private func connectSubtitlesObserver() {
        
        let temp = self.playSubtitlesUseCase
        self.playSubtitlesUseCase = nil
        self.playSubtitlesUseCase = temp
    }
}

// MARK: - Input Methods

extension PlayMediaWithSubtitlesUseCaseImpl {

    public func prepare(params session: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        updateStateHash()
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
        
        updateStateHash()
        return playMediaUseCase.play().mapResult()
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        switch state.value {
            
        case .initial, .loading, .loadFailed:
            return .failure(.noActiveMedia)
            
        default:
            updateStateHash()
            return playMediaUseCase.play(atTime: atTime).mapResult()
        }
    }
    
    public func pause() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        guard case .playing = state.value else {
            return .failure(.noActiveMedia)
        }
        
        updateStateHash()
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
     
        updateStateHash()
        
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

extension PlayMediaWithSubtitlesUseCaseImpl {
    
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
            subtitlesChangesObserver?.cancel()
            state.value = .stopped(session: session)
            
        case .playing:
            
            state.value = .playing(session: session, subtitlesState: currentState.subtitlesState)

            guard case .playing = state.value else {
                return
            }

            connectSubtitlesObserver()
            guard let playSubtitlesUseCase = playSubtitlesUseCase else {
                return
            }

            if case .playing = playSubtitlesUseCase.state.value {
                return
            }
            
            playSubtitlesUseCase.play()
            
        case .paused(_, let time):
            playSubtitlesUseCase?.pause()
            state.value = .paused(session: session, subtitlesState: currentState.subtitlesState, time: time)
            
        case .finished:
            
            subtitlesChangesObserver?.cancel()
            playSubtitlesUseCase?.stop()
            
            let stateHash = self.stateHash
            
            if let currentPosition = currentState.subtitlesState?.position {
                
                willChangeSubtitlesPosition.send(.init(from: currentPosition, to: nil))
    
                if isStateUpdated(hash: stateHash) {
                    return
                }
            }
            
            state.value = .finished(session: session)
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
