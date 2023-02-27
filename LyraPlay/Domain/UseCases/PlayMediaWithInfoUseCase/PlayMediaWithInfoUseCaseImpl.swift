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
    public let pronounceTranslationsState: CurrentValueSubject<PronounceTranslationsUseCaseState?, Never>
    
    private var currentMediaInfo: MediaInfo?
    private var currentSession: PlayMediaWithInfoSession?
    
    private var observers = Set<AnyCancellable>()
    
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
    
    public func prepare(session: PlayMediaWithInfoSession) async -> Result<Void, PlayMediaWithInfoUseCaseError> {
        
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
        return .success(())
    }
    
    public func play() -> Result<Void, PlayMediaWithInfoUseCaseError> {
        
        return playMediaWithTranslationsUseCase
            .play()
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
    
    func map() -> PlayMediaWithInfoUseCasePlayerState {
        
        switch self {
        
        case .initial:
            return .initial
        
        case .playing:
            return .playing
            
        case .pronouncingTranslations:
            return .pronouncingTranslations
            
        case .paused:
            return .paused
            
        case .stopped:
            return .stopped
            
        case .finished:
            return .finished
            
        case .loading, .loaded, .loadFailed:
            fatalError()
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
