//
//  PlayMediaWithTranslationsUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.08.2022.
//

import Foundation

// MARK: - Interfaces

public enum PlayMediaWithTranslationsUseCaseError: Error {
    
    case mediaFileNotFound
}

public enum PlayMediaWithTranslationsUseCaseState: Equatable {
    
    case initial
    case loading
    case playing(subtitlesPosition: SubtitlesPosition?)
    case pronouncingTranslations(subtitlesPosition: SubtitlesPosition?, data: PronounceTranslationsUseCaseStateData)
    case paused(subtitlesPosition: SubtitlesPosition?)
    case stopped
    case finished
}

public protocol PlayMediaWithTranslationsUseCaseInput {
    
    func play(
        mediaId: UUID,
        nativeLanguage: String,
        learningLanguage: String,
        at: TimeInterval
    ) async -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func pause() -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func stop() -> Result<Void, PlayMediaWithTranslationsUseCaseError>
}

public protocol PlayMediaWithTranslationsUseCaseOutput {
    
    var state: Observable<PlayMediaWithTranslationsUseCaseState> { get }
}

public protocol PlayMediaWithTranslationsUseCase: PlayMediaWithTranslationsUseCaseOutput, PlayMediaWithTranslationsUseCaseInput {
}

// MARK: - Implementations

public final class DefaultPlayMediaWithTranslationsUseCase: PlayMediaWithTranslationsUseCase {
    
    struct Session: Equatable {
        
        var mediaId: UUID
        var learningLanguage: String
        var nativeLanguage: String
    }
    
    // MARK: - Properties
    
    private let playMediaUseCase: PlayMediaUseCase
    private let loadSubtitlesUseCase: LoadSubtitlesUseCase
    private let playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory
    private let provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase
    private let pronounceTranslationsUseCase: PronounceTranslationsUseCase
    
    public let state: Observable<PlayMediaWithTranslationsUseCaseState> = .init(.initial)
    
    private var currentSession: Session?
    
    private var playSubtitlesUseCase: PlaySubtitlesUseCase? 
    
    // MARK: - Computed properties
    
    private var currentSubtitlesPosition: SubtitlesPosition? {
        
        guard let playSubtitlesUseCase = self.playSubtitlesUseCase else {
            return nil
        }
        
        switch playSubtitlesUseCase.state.value {
            
        case .initial, .stopped, .finished:
            return nil
            
        case .paused(let position), .playing(let position):
            return position
        }
    }
    
    // MARK: - Initializers
    
    public init(
        playMediaUseCase: PlayMediaUseCase,
        loadSubtitlesUseCase: LoadSubtitlesUseCase,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase,
        pronounceTranslationsUseCase: PronounceTranslationsUseCase
    ) {
        
        self.playMediaUseCase = playMediaUseCase
        self.loadSubtitlesUseCase = loadSubtitlesUseCase
        self.playSubtitlesUseCaseFactory = playSubtitlesUseCaseFactory
        self.provideTranslationsToPlayUseCase = provideTranslationsToPlayUseCase
        self.pronounceTranslationsUseCase = pronounceTranslationsUseCase
        
        observeMediaState()
        observePronouncingTranslations()
    }
}

// MARK: - Input methods

extension DefaultPlayMediaWithTranslationsUseCase {
    
    private func prepareResources(session: Session) async {
        
        let prevSession = currentSession
        
        if
            prevSession?.mediaId == session.mediaId,
            prevSession?.nativeLanguage == session.nativeLanguage,
            prevSession?.nativeLanguage == session.nativeLanguage
        {
            return
        }
        
        await playMediaUseCase.prepare(mediaId: session.mediaId)
        
        let loadSubtitlesResult = await loadSubtitlesUseCase.load(
            for: session.mediaId,
            language: session.learningLanguage
        )
        
        if case .success(let subtitles) = loadSubtitlesResult {
            
            self.playSubtitlesUseCase = playSubtitlesUseCaseFactory.create(with: subtitles)
            await provideTranslationsToPlayUseCase.prepare(
                params: .init(
                    mediaId: session.mediaId,
                    nativeLanguage: session.nativeLanguage,
                    learningLanguage: session.learningLanguage,
                    subtitles: subtitles
                )
            )
            
            await self.provideTranslationsToPlayUseCase.prepare(
                params: .init(
                    mediaId: session.mediaId,
                    nativeLanguage: session.nativeLanguage,
                    learningLanguage: session.learningLanguage,
                    subtitles: subtitles
                )
            )
        }
    }
    
    public func play(
        mediaId: UUID,
        nativeLanguage: String,
        learningLanguage: String,
        at: TimeInterval
    ) async -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        self.state.value = .loading
        
        let session = Session(mediaId: mediaId, learningLanguage: learningLanguage, nativeLanguage: nativeLanguage)
        
        await prepareResources(session: session)
        await playMediaUseCase.play()
        
        return .success(())
    }
    
    public func pause() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        playSubtitlesUseCase?.pause()
        pronounceTranslationsUseCase.pause()
        
        return .success(())
    }
    
    public func stop() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        pronounceTranslationsUseCase.stop()
        playSubtitlesUseCase?.stop()
        currentSession = nil
        
        return .success(())
    }
    
    private func didFinish() {
        
        self.pronounceTranslationsUseCase.stop()
        self.playSubtitlesUseCase?.stop()
        
        self.state.value = .finished
    }
}

// MARK: - Playing translations

extension DefaultPlayMediaWithTranslationsUseCase {
    
    private func pronounceCurrentTranslationItem(translations: TranslationsToPlay) async {
        
        switch translations.data {
            
        case .single(let translation):
            await self.pronounceTranslationsUseCase.pronounceSingle(translation: translation)
            
        case .groupAfterSentence(let translations):
            await self.pronounceTranslationsUseCase.pronounceGroup(translations: translations)
        }
    }
    
    private func updateSubtitlesPosition(_ newPosition: SubtitlesPosition?) {
        
        guard currentSubtitlesPosition != newPosition else {
            return
        }
        
        switch self.state.value {
        case .initial, .finished, .stopped, .loading, .pronouncingTranslations, .paused:
            break
            
        case .playing:
            self.state.value = .playing(subtitlesPosition: newPosition)
        }
    }
}


// MARK: - Update state

extension DefaultPlayMediaWithTranslationsUseCase {
    
    private func updateState(_ newState: PlayMediaUseCaseState) {
        
        switch newState {
            
        case .initial, .loading, .loaded, .stopped, .failedLoad:
            return
            
        case .playing:
            
            playSubtitlesUseCase?.play()
            self.state.value = .playing(subtitlesPosition: self.currentSubtitlesPosition)
            
        case .paused, .interrupted:
            self.state.value = .paused(subtitlesPosition: self.currentSubtitlesPosition)
            
        case .finished:
            break
            
            // FIXME: Add handling
            
            //            guard
            //                let currentSubtitlesPosition = currentSubtitlesPosition,
            //                !provideTranslationsToPlayUseCase.hasNext(from: currentSubtitlesPosition)
            //            else {
            //                return
            //            }
            //
            //            self.didFinish()
        }
    }
    
    private func observeMediaState() {
    }
    
    private func playTranslationAfterSubtitlesPositionChange(position newPosition: SubtitlesPosition?) {
        
        guard let currentPosition = currentSubtitlesPosition else {
            return
        }
        
        guard currentPosition != newPosition else {
            return
        }
        
        
        let isSentenceFinished = (newPosition == nil || newPosition!.sentenceIndex != currentPosition.sentenceIndex)
        
        let positionToPlay = isSentenceFinished ? .sentence(currentPosition.sentenceIndex) : currentPosition
        
        Task {
            
            let translations = await self.provideTranslationsToPlayUseCase.getTranslationsToPlay(for: positionToPlay)
            guard let translations = translations else {
                
                self.updateSubtitlesPosition(newPosition)
                return
            }
            
            self.playSubtitlesUseCase?.pause()
            await self.playMediaUseCase.pause()
            await self.pronounceCurrentTranslationItem(translations: translations)
        }
    }
    
    private func updateState(_ newState: PlaySubtitlesUseCaseState) {
        
        switch newState {
            
        case .initial, .stopped, .finished:
            break
            
        case .paused(let position):
            self.updateSubtitlesPosition(position)
            
        case .playing(let position):
            playTranslationAfterSubtitlesPositionChange(position: position)
        }
    }
    
    
    private func resumePlayingAfterPronunciationBlock() {
        
        let currentState = self.state.value
        
        switch currentState {
            
        case .initial, .playing, .paused, .stopped, .finished, .loading:
            break
            
        case .pronouncingTranslations:
            
            guard case .finished = self.playMediaUseCase.state.value else {
                
                self.state.value = .finished
                return
            }
            
            //                self.playSubtitlesUseCase.resume()
            //                self.playMediaUseCase.resume()
            self.state.value = .playing(subtitlesPosition: self.currentSubtitlesPosition)
        }
    }
    
    private func updateState(_ newState: PronounceTranslationsUseCaseState) {
        
        switch newState {
            
        case .paused, .stopped:
            break
            
        case .playing(let stateData):
            self.state.value = .pronouncingTranslations(subtitlesPosition: self.currentSubtitlesPosition, data: stateData)
            
        case .finished:
            resumePlayingAfterPronunciationBlock()
        }
    }
    
    private func observePronouncingTranslations() {
        
        self.pronounceTranslationsUseCase.state.observeIgnoreInitial(on: self) { [weak self] in self?.updateState($0) }
    }
}
