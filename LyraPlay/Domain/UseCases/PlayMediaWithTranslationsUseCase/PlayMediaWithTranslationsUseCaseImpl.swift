//
//  PlayMediaWithTranslationsUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation
import Combine

public final class PlayMediaWithTranslationsUseCaseImpl: PlayMediaWithTranslationsUseCase {

    // MARK: - Properties

    private let playMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCase
    private let playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory
    private let provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase
    private let pronounceTranslationsUseCase: PronounceTranslationsUseCase
    
    public let state = PublisherWithSession<PlayMediaWithTranslationsUseCaseState, Never>(.initial)
    
    private var playMediaWithSubtitlesObserver: AnyCancellable?
    private var subtitlesChangesObserver: AnyCancellable?

    // MARK: - Initializers

    public init(
        playMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCase,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase,
        pronounceTranslationsUseCase: PronounceTranslationsUseCase
    ) {

        self.playMediaWithSubtitlesUseCase = playMediaWithSubtitlesUseCase
        self.playSubtitlesUseCaseFactory = playSubtitlesUseCaseFactory
        self.provideTranslationsToPlayUseCase = provideTranslationsToPlayUseCase
        self.pronounceTranslationsUseCase = pronounceTranslationsUseCase
        
        connectMediaObserver()
        
        subtitlesChangesObserver = playMediaWithSubtitlesUseCase.willChangeSubtitlesPosition.sink { [weak self] in self?.playTranslationAfterSubtitlesPositionChange($0) }
    }
    
    deinit {
        
        subtitlesChangesObserver?.cancel()
        playMediaWithSubtitlesObserver?.cancel()
    }
    
    private func connectMediaObserver() {
        
        playMediaWithSubtitlesObserver = playMediaWithSubtitlesUseCase.state.dropFirst().sink { [weak self] in self?.updateState($0) }
    }
}

// MARK: - Input Methods

extension PlayMediaWithTranslationsUseCaseImpl {

    public func prepare(session: PlayMediaWithTranslationsSession) async -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        state.value = .loading(session: session)
        
        let result = await playMediaWithSubtitlesUseCase.prepare(
            params: .init(mediaId: session.mediaId, subtitlesLanguage: session.learningLanguage)
        )
        
        guard case .success = result else {
            
            state.value = .loadFailed(session: session)
            return .failure(result.error!.map())
        }
        
        if Task.isCancelled {
            state.value = .loadFailed(session: session)
            return .failure(.taskCancelled)
        }
        
        guard case .loaded(_, let subtitlesData) = playMediaWithSubtitlesUseCase.state.value else {
            
            state.value = .loadFailed(session: session)
            return .failure(.internalError(nil))
        }
        
        guard let subtitles = subtitlesData?.subtitles else {
            
            state.value = .loaded(session: session, subtitlesState: nil)
            return .success(())
        }
        
        await provideTranslationsToPlayUseCase.prepare(
            params: .init(
                mediaId: session.mediaId,
                nativeLanguage: session.nativeLanguage,
                learningLanguage: session.learningLanguage,
                subtitles: subtitles
            )
        )
        
        state.value = .loaded(session: session, subtitlesState: .init(position: nil, subtitles: subtitles))
        return .success(())
    }
    
    public func play() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return playMediaWithSubtitlesUseCase.play().mapResult()
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return playMediaWithSubtitlesUseCase.play(atTime: atTime).mapResult()
    }
    
    public func pause() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        pronounceTranslationsUseCase.stop()
        return playMediaWithSubtitlesUseCase.pause().mapResult()
    }
    
    public func stop() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        pronounceTranslationsUseCase.stop()
        return playMediaWithSubtitlesUseCase.stop().mapResult()
    }
}


// MARK: - Update state

extension PlayMediaWithTranslationsUseCaseImpl {
    
    private func updateState(_ newState: PlayMediaWithSubtitlesUseCaseState) {
        
        let currentState = state.value
        
        guard let session = currentState.session else {
            return
        }
        
        switch newState {
            
        case .initial, .loading, .loadFailed, .loaded:
            break
            
        case .paused(_, let subtitlesState, let time):
            state.value = .paused(session: session, subtitlesState: subtitlesState, time: time)
            
        case .stopped:
            state.value = .stopped(session: session)
            
        case .finished:
            state.value = .finished(session: session)
    
        case .playing(_, let subtitlesState):
            state.value = .playing(session: session, subtitlesState: subtitlesState)
        }
    }
}

// MARK: - Playing translations

extension PlayMediaWithTranslationsUseCaseImpl {

    private func pronounceCurrentTranslationItem(_ translations: TranslationsToPlayData) -> AsyncThrowingStream<PronounceTranslationsUseCaseState, Error> {
        
        switch translations {
            
        case .single(let translation):
            return self.pronounceTranslationsUseCase.pronounceSingle(translation: translation)
            
        case .groupAfterSentence(let translations):
            return self.pronounceTranslationsUseCase.pronounceGroup(translations: translations)
        }
    }
    
    private func playTranslationAfterSubtitlesPositionChange(_ data: WillChangeSubtitlesPositionData) {

        let currentState = state.value
        
        guard
            let currentPosition = data.from,
            case .playing = currentState,
            let session = currentState.session,
            let subtitlesState = state.value.subtitlesState
        else {
            return
        }
        
        let nextPosition = data.to
        let isEndOfSentence = nextPosition?.sentenceIndex != currentPosition.sentenceIndex
        let isEndOfTimeMark = currentPosition.timeMarkIndex != nil
        let canPlay = isEndOfSentence || isEndOfTimeMark
        
        guard
            canPlay,
            let translationsToPlay = provideTranslationsToPlayUseCase.getTranslationsToPlay(for: currentPosition)
        else {
            return
        }
        
        playMediaWithSubtitlesObserver?.cancel()
        let _ = playMediaWithSubtitlesUseCase.pause()
        
        connectMediaObserver()

        Task {
            
            for try await pronounciationState in pronounceCurrentTranslationItem(translationsToPlay) {
                
                switch pronounciationState {
                
                case .stopped, .paused:
                    return

                case .finished, .loading:
                    continue
                    
                case .playing(let stateData):
                    
                    do {
                        try state.send(
                            .pronouncingTranslations(
                                session: session,
                                subtitlesState: subtitlesState,
                                data: stateData
                            )
                        )
                        
                    } catch is PublisherFlowIsChanged {
                        return
                    }
                }
            }
            
            let _ = playMediaWithSubtitlesUseCase.play()
        }
    }
}

// MARK: - Error Mapping

fileprivate extension PlayMediaWithSubtitlesUseCaseError {
    
    func map() -> PlayMediaWithTranslationsUseCaseError {
        
        switch self {
            
        case .mediaFileNotFound:
            return .mediaFileNotFound
            
        case .internalError(let err):
            return .internalError(err)
            
        case .noActiveMedia:
            return .noActiveMedia
        }
    }
}

// MARK: - Result Mapping

fileprivate extension Result where Failure == PlayMediaWithSubtitlesUseCaseError  {
    
    func mapResult() -> Result<Success, PlayMediaWithTranslationsUseCaseError> {
        
        guard case .success(let value) = self else {
            return .failure(self.error!.map())
        }
        
        return .success(value)
    }
}