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
    
    public var state: CurrentValueSubject<PlayMediaWithSubtitlesUseCaseState, Never> = .init(.noActiveSession)
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
        state.value = .activeSession(session, .loading)
        
        let loadMediaResult = await playMediaUseCase.prepare(mediaId: session.mediaId)
        
        guard case .success = loadMediaResult else {
            
            state.value = .activeSession(session, .loadFailed)
            return loadMediaResult.mapResult()
        }
        
        let loadSubtitlesResult = await loadSubtitlesUseCase.load(
            for: session.mediaId,
            language: session.subtitlesLanguage
        )
        
        guard case .success(let subtitles) = loadSubtitlesResult else {
            
            state.value = .activeSession(session, .loaded(.initial, nil))
            return .success(())
        }
        
        playSubtitlesUseCase = playSubtitlesUseCaseFactory.make(subtitles: subtitles)
        
        self.state.value = .activeSession(
            session,
            .loaded(.initial, .init(position: nil, subtitles: subtitles))
        )
        
        return .success(())
    }
    
    public func play() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {

        switch state.value {
            
        case .noActiveSession, .activeSession(_, .loadFailed), .activeSession(_, .loading):
            return .failure(.noActiveMedia)
            
        default:
            updateStateHash()
            return playMediaUseCase.play().mapResult()
        }
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        switch state.value {
            
        case .noActiveSession, .activeSession(_, .loadFailed), .activeSession(_, .loading):
            return .failure(.noActiveMedia)
            
        default:
            updateStateHash()
            return playMediaUseCase.play(atTime: atTime).mapResult()
        }
    }
    
    public func pause() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        guard case .activeSession = state.value else {
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
        
        case .activeSession(_, .loaded(.playing, _)), .activeSession(_, .loaded(.paused, _)):
            return playMediaUseCase.stop().mapResult()

        case .activeSession(_, .loaded(.initial, _)):
            releaseResources()
            
        case .activeSession(_, .loading):
            stopLoading()
            
        default:
            break
        }
        
        return .success(())
    }
    
    public func togglePlay() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        switch state.value {
        
        case .activeSession(_, .loaded(.playing, _)):
            return pause()
            
        case .activeSession(_, .loaded(.paused, _)):
            return play()
            
        default:
            return .failure(.noActiveMedia)
        }
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
            
        case .noActiveSession, .activeSession(_, .loadFailed), .activeSession(_, .loading):
            return
            
        case .activeSession(let session, .loaded(.playing, _)):
            
            state.value = .activeSession(
                session,
                .loaded(.playing, newSubtitlesState)
            )
            
        case .activeSession(let session, .loaded(.paused(let time), _)):
            state.value = .activeSession(
                session,
                .loaded(.paused(time: time), newSubtitlesState)
            )
            
        default:
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
            state.value = .noActiveSession
            
        case .playing:
            
            state.value = .activeSession(
                session,
                .loaded(.playing, currentState.subtitlesState)
            )

            guard case .activeSession(_, .loaded(.playing, _)) = state.value else {
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
            state.value = .activeSession(session, .loaded(.paused(time: time), currentState.subtitlesState))
            
        case .finished:
            
            subtitlesChangesObserver?.cancel()
            let currentPosition = playSubtitlesUseCase?.state.value.position
            let subtitlesState = currentState.subtitlesState
            
            playSubtitlesUseCase?.stop()
            
            let stateHash = self.stateHash
            
            if let currentPosition = currentPosition {
                
                willChangeSubtitlesPosition.send(.init(from: currentPosition, to: nil))
    
                if isStateUpdated(hash: stateHash) {
                    return
                }
            }
            
            self.state.value = .activeSession(
                session,
                .loaded(
                    .finished,
                    subtitlesState
                )
            )
        }
    }
}

// MARK: - Error Mapping

extension PlayMediaUseCaseError {
    
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

extension PlayMediaWithSubtitlesUseCaseError {
    
    func map() -> PlayMediaUseCaseError {
        
        switch self {
        
        case .mediaFileNotFound:
            return .trackNotFound
            
        case .internalError(let error):
            return .internalError(error)
            
        case .noActiveMedia:
            return .noActiveTrack
        }
    }
}

// MARK: - Result Mapping

extension Result where Failure == PlayMediaUseCaseError  {
    
    func mapResult() -> Result<Success, PlayMediaWithSubtitlesUseCaseError> {
        
        guard case .success(let value) = self else {
            return .failure(self.error!.map())
        }
        
        return .success(value)
    }
}

extension Result where Failure == PlayMediaWithSubtitlesUseCaseError  {
    
    func mapResult() -> Result<Success, PlayMediaUseCaseError> {
        
        guard case .success(let value) = self else {
            return .failure(self.error!.map())
        }
        
        return .success(value)
    }
}
