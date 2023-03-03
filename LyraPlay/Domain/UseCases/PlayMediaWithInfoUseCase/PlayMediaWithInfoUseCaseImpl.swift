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
    
    private var observers = Set<AnyCancellable>()
    
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
    }
    
    // MARK: - Methods
    
    public func prepare(session: PlayMediaWithInfoSession) async -> Result<Void, PlayMediaWithInfoUseCaseError> {
        
        observers.removeAll()
        
        state.value = .activeSession(session, .loading)
        
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
            state.value = .activeSession(session, .loadFailed)
            return .failure(resultLoadingInfo.error!.map())
        }
        
        if case .failure(let error) = await loadingTranslationsPromise {
            state.value = .activeSession(session, .loadFailed)
            return .failure(error.map())
        }

        currentMediaInfo = info
        state.value = .activeSession(session, .loaded(.initial, info))
        
        startObservingState()
        return .success(())
    }
    
    private func update(state: PlayMediaWithTranslationsUseCaseState) {
        
        guard let mediaInfo = currentMediaInfo else {
            return
        }
        
        switch state {
            
        case .noActiveSession:
            self.state.value = .noActiveSession
            
        case .activeSession(let session, let playerState):
            self.state.value = .activeSession(session.map(), playerState.map(withMediaInfo: mediaInfo))
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

extension PlayMediaWithTranslationsUseCasePlayerState {
    
    func map(withMediaInfo mediaInfo: MediaInfo) -> PlayMediaWithInfoUseCaseLoadState {
        
        switch self {
        
        case .initial:
            return .loaded(.initial, mediaInfo)
        
        case .playing:
            return .loaded(.playing, mediaInfo)
            
        case .pronouncingTranslations:
            return .loaded(.pronouncingTranslations, mediaInfo)
            
        case .paused:
            return .loaded(.paused, mediaInfo)
            
        case .stopped:
            return .loaded(.stopped, mediaInfo)
            
        case .finished:
            return .loaded(.finished, mediaInfo)
            
        case .loading:
            return .loading
            
        case .loaded:
            return .loaded(.initial, mediaInfo)
            
        case .loadFailed:
            return .loadFailed
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
