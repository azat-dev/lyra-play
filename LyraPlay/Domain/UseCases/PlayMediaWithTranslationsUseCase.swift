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
        loadSubtitlesUseCase: LoadSubtitlesUseCase,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase,
        pronounceTranslationsUseCase: PronounceTranslationsUseCase,
        translationsScheduler: Scheduler
    ) {
        
        self.loadSubtitlesUseCase = loadSubtitlesUseCase
        self.playSubtitlesUseCaseFactory = playSubtitlesUseCaseFactory
        self.provideTranslationsToPlayUseCase = provideTranslationsToPlayUseCase
        self.pronounceTranslationsUseCase = pronounceTranslationsUseCase
        self.translationsScheduler = translationsScheduler
        
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
            await startPlayingTranslations()
        }
        
        return .success(())
    }
    
    private func updateSubtitlesPosition(_ newPosition: SubtitlesPosition?) {
        
        switch self.state.value {
        case .finished, .stopped, .initial:
            break
            
        case .playing:
            self.state.value = .playing(subtitlesPosition: newPosition)
            
        case .pronouncingTranslations( _, let data):
            self.state.value = .pronouncingTranslations(subtitlesPosition: newPosition, data: data)
            
        case .paused:
            self.state.value = .paused(subtitlesPosition: newPosition)
        }
    }
    
    private func observePlayingSubtitles() {
        
        playSubtitlesUseCase?.state.observeIgnoreInitial(on: self) { playSubtitlesState in
            
            switch playSubtitlesState {
            
            case .initial:
                break
                
            case .playing(let position):
                self.state.value = .playing(subtitlesPosition: position)
            
            case .paused(let position):
                self.updateSubtitlesPosition(position)
                
            case .stopped, .finished:
                break
            }
        }
    }
    
    private func startPlayingTranslations() async {
        
        translationsScheduler.start(at: 0) { [weak self] _ in
            
            guard let self = self else {
                return
            }
            
            guard
                let currentTranslation = self.provideTranslationsToPlayUseCase.currentItem
            else {
                return
            }
            
            switch currentTranslation.data {
                
            case .single(let translation):
                Task {
                    await self.pronounceTranslationsUseCase.pronounceSingle(translation: translation)
                }
                
            case .groupAfterSentence(let translations):
                Task {
                    await self.pronounceTranslationsUseCase.pronounceGroup(translations: translations)
                }
            }
        }
    }
    
    private func resuemPlaying() {
        
    }
    
    private func observePronouncingTranslations() {
        
        self.pronounceTranslationsUseCase.state.observeIgnoreInitial(on: self) { [weak self] pronounceState in
            
            guard let self = self else {
                return
            }
            
            switch pronounceState {
                
            case .playing(let stateData):
                
                self.state.value = .pronouncingTranslations(
                    subtitlesPosition: self.currentSubtitlesPosition,
                    data: stateData
                )
                
            case .paused:
                let _ = self.pause()
                
            case .stopped:
                let _ = self.stop()
                
            case .finished:
                self.resuemPlaying()
            }
        }
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
}
