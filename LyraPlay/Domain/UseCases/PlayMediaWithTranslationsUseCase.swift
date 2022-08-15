//
//  PlayMediaWithTranslationsUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.08.2022.
//

import Foundation
import Combine

// MARK: - Interfaces

public enum PlayMediaWithTranslationsUseCaseError: Error {
    
    case mediaFileNotFound
    case noActiveMedia
    case internalError(Error?)
    case taskCancelled
}

public struct PlayMediaWithTranslationsSession: Equatable {
    
    public let mediaId: UUID
    public let learningLanguage: String
    public let nativeLanguage: String
    
    public init(
        mediaId: UUID,
        learningLanguage: String,
        nativeLanguage: String
    ) {
        
        self.mediaId = mediaId
        self.learningLanguage = learningLanguage
        self.nativeLanguage = nativeLanguage
    }
}

public enum PlayMediaWithTranslationsUseCaseState: Equatable {
    
    case initial
    
    case loading(session: PlayMediaWithTranslationsSession)
    
    case loadFailed(session: PlayMediaWithTranslationsSession)
    
    case loaded(session: PlayMediaWithTranslationsSession, subtitlesState: SubtitlesState?)
    
    case playing(session: PlayMediaWithTranslationsSession, subtitlesState: SubtitlesState?)
    
    case pronouncingTranslations(session: PlayMediaWithTranslationsSession, subtitlesState: SubtitlesState?, data: PronounceTranslationsUseCaseStateData)
    
    case interrupted(session: PlayMediaWithTranslationsSession, subtitlesState: SubtitlesState?, time: TimeInterval)
    
    case paused(session: PlayMediaWithTranslationsSession, subtitlesState: SubtitlesState?, time: TimeInterval)
    
    case stopped(session: PlayMediaWithTranslationsSession)
    
    case finished(session: PlayMediaWithTranslationsSession)
}

extension PlayMediaWithTranslationsUseCaseState {
    
    public var session: PlayMediaWithTranslationsSession? {
        
        switch self {
        
        case .initial:
            return nil
            
        case .loading(let session), .loadFailed(let session), .loaded(let session, _), .playing(let session, _), .pronouncingTranslations(let session, _, _), .paused(let session, _, _), .interrupted(let session, _, _), .stopped(let session), .finished(let session):
        
            return session
        }
    }
}

public protocol PlayMediaWithTranslationsUseCaseInput {
    
    func prepare(session: PlayMediaWithTranslationsSession) async -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func play() async -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func play(atTime: TimeInterval) async -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func pause() -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func stop() -> Result<Void, PlayMediaWithTranslationsUseCaseError>
}

public protocol PlayMediaWithTranslationsUseCaseOutput {
    
    var state: CurrentValueSubject<PlayMediaWithTranslationsUseCaseState, Never> { get }
}

public protocol PlayMediaWithTranslationsUseCase: PlayMediaWithTranslationsUseCaseOutput, PlayMediaWithTranslationsUseCaseInput {
}

// MARK: - Implementations

public final class DefaultPlayMediaWithTranslationsUseCase: PlayMediaWithTranslationsUseCase {
    
    // MARK: - Properties
    
    private let playMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCase
    private let playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory
    private let provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase
    private let pronounceTranslationsUseCase: PronounceTranslationsUseCase
    
    public let state = CurrentValueSubject<PlayMediaWithTranslationsUseCaseState, Never>(.initial)
    
    private var playMediaWithSubtitlesObserver: AnyCancellable?
    
    // MARK: - Computed properties
    
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
        
        playMediaWithSubtitlesObserver = playMediaWithSubtitlesUseCase.state.sink { [weak self] in self?.updateState($0) }
    }
    
    deinit {
        playMediaWithSubtitlesObserver?.cancel()
    }
}

// MARK: - Input methods

extension DefaultPlayMediaWithTranslationsUseCase {
    
    public func prepare(session: PlayMediaWithTranslationsSession) async -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        state.value = .loading(session: session)
        
        let result = await playMediaWithSubtitlesUseCase.prepare(
            params: .init(mediaId: session.mediaId, subtitlesLanguage: session.learningLanguage)
        )
        
        guard case .success = result else {
            
            state.value = .loadFailed(session: session)
            return .failure(map(error: result.error!))
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
    
    public func play() async -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        let result = await playMediaWithSubtitlesUseCase.play()
        
        guard case .success = result else {
            return .failure(map(error: result.error!))
        }
        
        return .success(())
    }
    
    public func play(atTime: TimeInterval) async -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        let result = await playMediaWithSubtitlesUseCase.play(atTime: atTime)
        
        guard case .success = result else {
            return .failure(map(error: result.error!))
        }
        
        return .success(())
    }
    
    
    
    public func pause() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        //        playMediaWithSubtitlesUseCase.pause()
        //        pronounceTranslationsUseCase.pause()
        
        return .success(())
    }
    
    public func stop() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        //
        //        pronounceTranslationsUseCase.stop()
        //        playMediaWithSubtitlesUseCase.stop()
        
        return .success(())
    }
}

// MARK: - Playing translations
//
//extension DefaultPlayMediaWithTranslationsUseCase {
//
//    private func pronounceCurrentTranslationItem(translations: TranslationsToPlay) async {
//
//        switch translations.data {
//
//        case .single(let translation):
//            await self.pronounceTranslationsUseCase.pronounceSingle(translation: translation)
//
//        case .groupAfterSentence(let translations):
//            await self.pronounceTranslationsUseCase.pronounceGroup(translations: translations)
//        }
//    }
//}


// MARK: - Update state

extension DefaultPlayMediaWithTranslationsUseCase {

    private func updateState(_ newState: PlayMediaWithSubtitlesUseCaseState) {
        
        guard let session = state.value.session else {
            return
        }

        switch newState {
            
        case .initial:
            break
            
        case .loading, .loadFailed, .loaded:
            break

        case .playing(_, let subtitlesState):
            state.value = .playing(session: session, subtitlesState: subtitlesState)
            
        case .interrupted(_, let subtitlesState, let time):
            state.value = .interrupted(session: session, subtitlesState: subtitlesState, time: time)
            
        case .paused(_, let subtitlesState, let time):
            state.value = .paused(session: session, subtitlesState: subtitlesState, time: time)
            
        case .stopped:
            state.value = .stopped(session: session)
            
        case .finished:
            state.value = .finished(session: session)
        }
    }
//
//    private func observeMediaState() {
//    }
//
//    private func playTranslationAfterSubtitlesPositionChange(position newPosition: SubtitlesPosition?) {
//
//        guard let currentPosition = currentSubtitlesPosition else {
//            return
//        }
//
//        guard currentPosition != newPosition else {
//            return
//        }
//
//
//        let isSentenceFinished = (newPosition == nil || newPosition!.sentenceIndex != currentPosition.sentenceIndex)
//
//        let positionToPlay = isSentenceFinished ? .sentence(currentPosition.sentenceIndex) : currentPosition
//
//        Task {
//
//            let translations = await self.provideTranslationsToPlayUseCase.getTranslationsToPlay(for: positionToPlay)
//            guard let translations = translations else {
//
//                self.updateSubtitlesPosition(newPosition)
//                return
//            }
//
//            self.playSubtitlesUseCase?.pause()
//            await self.playMediaUseCase.pause()
//            await self.pronounceCurrentTranslationItem(translations: translations)
//        }
//    }
//
//    private func updateState(_ newState: PlaySubtitlesUseCaseState) {
//
//        switch newState {
//
//        case .initial, .stopped, .finished:
//            break
//
//        case .paused(let position):
//            self.updateSubtitlesPosition(position)
//
//        case .playing(let position):
//            playTranslationAfterSubtitlesPositionChange(position: position)
//        }
//    }
//
//
//    private func resumePlayingAfterPronunciationBlock() {
//
//        let currentState = self.state.value
//
//        switch currentState {
//
//        case .initial, .playing, .paused, .stopped, .finished, .loading:
//            break
//
//        case .pronouncingTranslations:
//
//            guard case .finished = self.playMediaUseCase.state.value else {
//
//                self.state.value = .finished
//                return
//            }
//
//            //                self.playSubtitlesUseCase.resume()
//            //                self.playMediaUseCase.resume()
//            self.state.value = .playing(subtitlesPosition: self.currentSubtitlesPosition)
//        }
//    }
//
//    private func updateState(_ newState: PronounceTranslationsUseCaseState) {
//
//        switch newState {
//
//        case .paused, .stopped:
//            break
//
//        case .playing(let stateData):
//            self.state.value = .pronouncingTranslations(subtitlesPosition: self.currentSubtitlesPosition, data: stateData)
//
//        case .finished:
//            resumePlayingAfterPronunciationBlock()
//        }
//    }
//
//    private func observePronouncingTranslations() {
//    }
}

// MARK: - Map Errors

extension DefaultPlayMediaWithTranslationsUseCase {
    
    private func map(error: PlayMediaWithSubtitlesUseCaseError) -> PlayMediaWithTranslationsUseCaseError {
        
        switch error {
            
        case .mediaFileNotFound:
            return .mediaFileNotFound
            
        case .internalError(let err):
            return .internalError(err)
            
        case .noActiveMedia:
            return .noActiveMedia
        }
    }
}
