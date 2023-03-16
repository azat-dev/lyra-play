//
//  PlayMediaWithInfoUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.09.22.
//

import Foundation
import Combine

public final class PlayMediaWithInfoUseCaseImpl: PlayMediaWithInfoUseCase {
    
    // MARK: - Properties
    
    private let playMediaWithTranslationsUseCase: PlayMediaWithTranslationsUseCase
    private let showMediaInfoUseCaseFactory: ShowMediaInfoUseCaseFactory
    
    public let state = CurrentValueSubject<PlayMediaWithInfoUseCaseState, Never>(.noActiveSession)
    public let subtitlesState: CurrentValueSubject<SubtitlesState?, Never>
    public let pronounceTranslationsState: CurrentValueSubject<PronounceTranslationsUseCaseState, Never>
    
    private var currentMediaInfo: MediaInfo?
    private var currentSession: PlayMediaWithInfoSession?
    
    
    private let playerState = CurrentValueSubject<PlayMediaWithInfoUseCasePlayerState, Never>(.initial)
    private let loadState = CurrentValueSubject<PlayMediaWithInfoUseCaseLoadState, Never>(.loading)
    
    private var observers = Set<AnyCancellable>()
    private var playerStateObserver: AnyCancellable?
    
    public var currentTime: TimeInterval {
        return playMediaWithTranslationsUseCase.currentTime
    }
    
    public var duration: TimeInterval {
        return playMediaWithTranslationsUseCase.duration
    }
    
    // MARK: - Initializers
    
    public init(
        playMediaWithTranslationsUseCaseFactory: PlayMediaWithTranslationsUseCaseFactory,
        showMediaInfoUseCaseFactory: ShowMediaInfoUseCaseFactory
    ) {
        self.playMediaWithTranslationsUseCase = playMediaWithTranslationsUseCaseFactory.make()
        self.showMediaInfoUseCaseFactory = showMediaInfoUseCaseFactory
        
        self.subtitlesState = playMediaWithTranslationsUseCase.subtitlesState
        self.pronounceTranslationsState = playMediaWithTranslationsUseCase.pronounceTranslationsState
    }
    
    deinit {
        observers.removeAll()
        playerStateObserver = nil
    }
    
    // MARK: - Methods
    
    public func prepare(session: PlayMediaWithInfoSession) async -> Result<Void, PlayMediaWithInfoUseCaseError> {
        
        observers.removeAll()
        
        loadState.value = .loading
        state.value = .activeSession(session, loadState)
        
        async let loadingTranslationsPromise = playMediaWithTranslationsUseCase.prepare(
            session: .init(
                mediaId: session.mediaId,
                learningLanguage: session.learningLanguage,
                nativeLanguage: session.nativeLanguage
            )
        )
        
        let showMediaInfoUseCase = showMediaInfoUseCaseFactory.make()
        async let loadingInfoPromise = showMediaInfoUseCase.fetchInfo(trackId: session.mediaId)
        
        currentMediaInfo = nil
        
        let resultLoadingInfo = await loadingInfoPromise
        
        guard case .success(let info) = resultLoadingInfo else {
            loadState.value = .loadFailed
            return .failure(resultLoadingInfo.error!.map())
        }
        
        if case .failure(let error) = await loadingTranslationsPromise {
            loadState.value = .loadFailed
            return .failure(error.map())
        }

        currentMediaInfo = info
        
        playerState.value = .initial
        loadState.value = .loaded(playerState, info)
        
        startObservingState()
        return .success(())
    }
    
    private func pipePlayingState(
        from state: CurrentValueSubject<PlayMediaWithTranslationsUseCasePlayerState, Never>,
        withMediaInfo mediaInfo: MediaInfo
    ) {
        
        playerStateObserver = state.sink { [weak self] newState in
         
            guard let self = self else {
                return
            }

            switch newState {
                
            case .initial, .loading, .loaded, .loadFailed:
                self.playerState.value = .initial

            case .playing:
                self.playerState.value = .playing
                
            case .pronouncingTranslations:
                self.playerState.value = .pronouncingTranslations
                
            case .paused:
                self.playerState.value = .paused
                
            case .stopped:
                self.playerState.value = .stopped
                
            case .finished:
                self.playerState.value = .finished
            }
        }
    }
    
    private func update(state: PlayMediaWithTranslationsUseCaseState) {
        
        playerStateObserver = nil
        
        guard let mediaInfo = currentMediaInfo else {
            return
        }
        
        switch state {
            
        case .noActiveSession:
            self.state.value = .noActiveSession
            
        case .activeSession(let session, let sourcePlayerState):
            
            pipePlayingState(from: sourcePlayerState, withMediaInfo: mediaInfo)
            self.state.value = .activeSession(session.map(), loadState)
        }
    }
    
    private func startObservingState() {
        
        playMediaWithTranslationsUseCase.state.sink { [weak self] state in
            self?.update(state: state)
        }.store(in: &observers)
    }
    
    public func resume() -> Result<Void, PlayMediaWithInfoUseCaseError> {
        
        return playMediaWithTranslationsUseCase
            .resume()
            .mapResult()
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithInfoUseCaseError> {
        
        return playMediaWithTranslationsUseCase
            .play(atTime: atTime)
            .mapResult()
    }
    
    public func pause() -> Result<Void, PlayMediaWithInfoUseCaseError> {
        
        return playMediaWithTranslationsUseCase
            .pause()
            .mapResult()
    }
    
    public func stop() -> Result<Void, PlayMediaWithInfoUseCaseError> {
        
        return playMediaWithTranslationsUseCase
            .stop()
            .mapResult()
    }
    
    public func togglePlay() -> Result<Void, PlayMediaWithInfoUseCaseError> {
        
        return playMediaWithTranslationsUseCase
            .togglePlay()
            .mapResult()
    }
    
    public func setTime(_ time: TimeInterval) {
        
        playMediaWithTranslationsUseCase.setTime(time)
    }
}


// MARK: - Error Mappings

extension PlayMediaWithTranslationsUseCaseError {
    
    func map() -> PlayMediaWithInfoUseCaseError {
        
        switch self {
        
        case .mediaFileNotFound:
            return .mediaFileNotFound
        
        case .noActiveMedia:
            return .noActiveMedia
            
        case .internalError(let error):
            return .internalError(error)
            
        case .taskCancelled:
            return .taskCancelled
        }
    }
}

extension ShowMediaInfoUseCaseError {
    
    func map() -> PlayMediaWithInfoUseCaseError {

        switch self {
            
        case .trackNotFound:
            return .mediaFileNotFound
            
        case .internalError(let error):
            return .internalError(error)
        }
    }
}

extension Result where Failure == PlayMediaWithTranslationsUseCaseError {

    
    func mapResult() -> Result<Success, PlayMediaWithInfoUseCaseError> {
        
        guard case .success(let value) = self else {
            return .failure(self.error!.map())
        }
        
        return .success(value)
    }
}

extension PlayMediaWithTranslationsSession {
    
    func map() -> PlayMediaWithInfoSession {
        
        return .init(
            mediaId: mediaId,
            learningLanguage: learningLanguage,
            nativeLanguage: nativeLanguage
        )
    }
}
