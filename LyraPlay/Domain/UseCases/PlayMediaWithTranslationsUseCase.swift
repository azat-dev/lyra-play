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
    
    // MARK: - Properties
    
    private let playMediaUseCase: PlayMediaUseCase
    private let loadSubtitlesUseCase: LoadSubtitlesUseCase
    private let playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory
    private let provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase
    private let pronounceTranslationsUseCase: PronounceTranslationsUseCase
    private let translationsScheduler: Scheduler
    
    public let state: Observable<PlayMediaWithTranslationsUseCaseState> = .init(.initial)
    
    private var nativeSubtitles: Subtitles?
    private var playSubtitlesUseCase: PlaySubtitlesUseCase? {
        didSet {
            observePlayingSubtitles()
        }
    }
    
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
        pronounceTranslationsUseCase: PronounceTranslationsUseCase,
        translationsScheduler: Scheduler
    ) {
        
        self.playMediaUseCase = playMediaUseCase
        self.loadSubtitlesUseCase = loadSubtitlesUseCase
        self.playSubtitlesUseCaseFactory = playSubtitlesUseCaseFactory
        self.provideTranslationsToPlayUseCase = provideTranslationsToPlayUseCase
        self.pronounceTranslationsUseCase = pronounceTranslationsUseCase
        self.translationsScheduler = translationsScheduler
        
        observeMediaState()
        observePronouncingTranslations()
    }
}

// MARK: - Input methods

extension DefaultPlayMediaWithTranslationsUseCase {
    
    public func play(
        mediaId: UUID,
        nativeLanguage: String,
        learningLanguage: String,
        at: TimeInterval
    ) async -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        self.state.value = .loading
        
        let loadResult = await loadSubtitlesUseCase.load(for: mediaId, language: nativeLanguage)
        
        if case .success(let nativeSubtitles) = loadResult {
            
            self.nativeSubtitles = nativeSubtitles
            self.playSubtitlesUseCase = playSubtitlesUseCaseFactory.create(with: nativeSubtitles)
            
            await provideTranslationsToPlayUseCase.prepare(
                params: .init(
                    mediaId: mediaId,
                    nativeLanguage: nativeLanguage,
                    learningLanguage: learningLanguage,
                    subtitles: nativeSubtitles
                )
            )
            
            await playSubtitlesUseCase?.play(at: 0)
            startPlayingTranslations()
        }
        
        return .success(())
    }
    
    public func pause() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        playSubtitlesUseCase?.pause()
        translationsScheduler.pause()
        pronounceTranslationsUseCase.pause()
        
        return .success(())
    }
    
    public func stop() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        playSubtitlesUseCase?.stop()
        translationsScheduler.stop()
        provideTranslationsToPlayUseCase.beginNextExecution(from: 0)
        pronounceTranslationsUseCase.stop()
        
        return .success(())
    }
    
    private func didFinish() {
        
        self.playSubtitlesUseCase?.stop()
        self.playSubtitlesUseCase = nil
        self.pronounceTranslationsUseCase.stop()
        let _ = self.provideTranslationsToPlayUseCase.beginNextExecution(from: 0)
        translationsScheduler.stop()
        
        self.state.value = .finished
    }
}

// MARK: - Playing translations

extension DefaultPlayMediaWithTranslationsUseCase {
    
    private func pronounceCurrentTranslationItem() {
        
        guard
            let currentTranslation = self.provideTranslationsToPlayUseCase.currentItem
        else {
            return
        }
        
        Task {
            
            switch currentTranslation.data {
                
            case .single(let translation):
                await self.pronounceTranslationsUseCase.pronounceSingle(translation: translation)
                
            case .groupAfterSentence(let translations):
                await self.pronounceTranslationsUseCase.pronounceGroup(translations: translations)
            }
        }
    }
    
    private func startPlayingTranslations() {
        
        translationsScheduler.start(at: 0) { [weak self] _ in self?.pronounceCurrentTranslationItem() }
    }
    
    private func updateSubtitlesPosition(_ newPosition: SubtitlesPosition?) {
        
        switch self.state.value {
        case .initial, .finished, .stopped, .loading:
            break
            
        case .playing:
            self.state.value = .playing(subtitlesPosition: newPosition)
            
        case .pronouncingTranslations( _, let data):
            self.state.value = .pronouncingTranslations(subtitlesPosition: newPosition, data: data)
            
        case .paused:
            self.state.value = .paused(subtitlesPosition: newPosition)
        }
    }

}


// MARK: - Update state

extension DefaultPlayMediaWithTranslationsUseCase {
    
    private func updateState(_ newState: PlayMediaUseCaseState) {
        
        switch newState {
            
        case .initial, .loading, .loaded, .stopped:
            return
            
        case .playing:
            self.state.value = .playing(subtitlesPosition: self.currentSubtitlesPosition)
            
        case .paused, .interrupted:
            self.state.value = .paused(subtitlesPosition: self.currentSubtitlesPosition)
            
        case .finished:
            
            let hasNextPronounceEvent = self.provideTranslationsToPlayUseCase.getTimeOfNextEvent() != nil
            
            guard !hasNextPronounceEvent else {
                return
            }
            
            self.didFinish()
        }
    }
    
    private func observeMediaState() {
        
        playMediaUseCase.state.observeIgnoreInitial(on: self) { [weak self] in self?.updateState($0) }
    }
    
    private func updateState(_ newState: PlaySubtitlesUseCaseState) {
        
        switch newState {
            
        case .initial, .stopped, .finished:
            break
            
        case .playing(let position), .paused(let position):
            self.updateSubtitlesPosition(position)
        }
    }
    
    private func observePlayingSubtitles() {
        
        playSubtitlesUseCase?.state.observeIgnoreInitial(on: self) { [weak self] in self?.updateState($0) }
    }
    
    private func updateState(_ newState: PronounceTranslationsUseCaseState) {
        
        switch newState {
            
        case .paused, .stopped:
            break
            
        case .playing(let stateData):
            
            self.state.value = .pronouncingTranslations(subtitlesPosition: self.currentSubtitlesPosition, data: stateData)
            
        case .finished:
            
            switch self.state.value {
                
            case .initial, .playing, .paused, .stopped, .finished:
                break
                
            case .pronouncingTranslations:
                self.state.value = .playing(subtitlesPosition: self.currentSubtitlesPosition)
                break
            }
        }
    }
    
    private func observePronouncingTranslations() {
        
        self.pronounceTranslationsUseCase.state.observeIgnoreInitial(on: self) { [weak self] in self?.updateState($0) }
    }
}
