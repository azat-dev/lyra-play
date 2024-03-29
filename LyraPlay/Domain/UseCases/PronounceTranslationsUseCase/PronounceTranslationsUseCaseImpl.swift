//
//  PronounceTranslationsUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation
import Combine
import AVFAudio

public final class PronounceTranslationsUseCaseImpl: PronounceTranslationsUseCase {

    // MARK: - Properties

    private let textToSpeechConverter: TextToSpeechConverter
    private let audioPlayer: AudioPlayer
    public var state = CurrentValueSubject<PronounceTranslationsUseCaseState, Never>(.stopped)

    // MARK: - Initializers

    public init(
        textToSpeechConverter: TextToSpeechConverter,
        audioPlayer: AudioPlayer
    ) {

        self.textToSpeechConverter = textToSpeechConverter
        self.audioPlayer = audioPlayer
    }
}

// MARK: - Input Methods

extension PronounceTranslationsUseCaseImpl {
    
    private enum PronounciationState {
        case converting
        case failed
        case loading
        case playing
        case paused
        case stopped
        case finished
    }
    
    private func convert(translation: SubtitlesTranslationItem) async -> (original: Data?, translated: Data?) {
        
        let results = await [
            
            textToSpeechConverter.convert(
                text: translation.originalText,
                language: translation.originalTextLanguage
            ),
            textToSpeechConverter.convert(
                text: translation.translatedText,
                language: translation.translatedTextLanguage
            )
        ]
        
        return (
            try? results[0].get(),
            try? results[1].get()
        )
    }
    
    
    private func pronounce(translation: SubtitlesTranslationItem) -> AsyncThrowingStream<PronounciationState, Error> {
        
        return AsyncThrowingStream { continuation in
            
            Task {
                
                continuation.onTermination = { _ in
                    let _ = self.audioPlayer.stop()
                }
                
                continuation.yield(.converting)
                
                let converted = await convert(translation: translation)
                
                guard
                    let originalData = converted.original,
                    let translationData = converted.translated
                else {
                    continuation.finish(throwing: NSError())
                    return
                }
                
                var prepareResult = audioPlayer.prepare(
                    fileId: translation.translationId.uuidString,
                    data: originalData
                )
                
                guard case .success = prepareResult else {
                    continuation.finish(throwing: NSError())
                    return
                }
                
                continuation.yield(.playing)
                
                for try await playerState in audioPlayer.playAndWaitForEnd() {
                    
                    switch playerState {
                        
                    case .stopped:
                        continuation.yield(.stopped)
                        continuation.finish()
                        
                    case .paused:
                        continuation.yield(.paused)
                        continuation.finish()
                        return
                        
                    default:
                        break
                    }
                }
                
                prepareResult = audioPlayer.prepare(
                    fileId: translation.translationId.uuidString,
                    data: translationData
                )
                
                guard case .success = prepareResult else {
                    continuation.finish(throwing: NSError())
                    return
                }
                
                for try await playerState in audioPlayer.playAndWaitForEnd() {
                    
                    switch playerState {
                        
                    case .stopped:
                        continuation.yield(.stopped)
                        continuation.finish()
                        
                    case .paused:
                        continuation.yield(.paused)
                        continuation.finish()
                        return

                    default:
                        break
                    }
                }
                
                continuation.yield(.finished)
                continuation.finish()
            }
        }
    }
    
    public func pronounceSingle(translation: SubtitlesTranslationItem) -> AsyncThrowingStream<PronounceTranslationsUseCaseState, Error> {
        
        return AsyncThrowingStream { continuation in
            
            Task {
                
                for try await state in pronounce(translation: translation) {
                    
                    switch state {
                    case .converting, .loading:
                        self.state.value = .loading(.single(translation: translation))
                        continue
                        
                    case .failed:
                        self.state.value = .stopped
                        continuation.finish(throwing: NSError())
                        return

                    case .playing:
                        let newState: PronounceTranslationsUseCaseState = .playing(.single(translation: translation))
                        self.state.value = newState
                        continuation.yield(newState)
                    
                    case .paused:
                        let newState: PronounceTranslationsUseCaseState = .paused(.single(translation: translation))
                        self.state.value = newState
                        continuation.yield(newState)
                        continuation.finish()
                        return
                    
                    case .stopped:
                        self.state.value = .stopped
                        continuation.yield(.stopped)
                        continuation.finish()
                        return
                    
                    case .finished:
                        self.state.value = .finished
                        continuation.yield(.finished)
                        continuation.finish()
                        return
                    }
                }
            }
        }
    }
    
    public func pronounceGroup(translations: [SubtitlesTranslationItem]) -> AsyncThrowingStream<PronounceTranslationsUseCaseState, Error> {
        
        return AsyncThrowingStream { continuation in
            
            Task {
                for translationIndex in 0..<translations.count {
                    
                    let translation = translations[translationIndex]
                    continuation.yield(.playing(.group(translations: translations, currentTranslationIndex: translationIndex)))
                    
                    for try await state in pronounce(translation: translation) {
                        
                        switch state {
                        case .finished:
                            continue
                            
                        case .converting, .loading:
                            
                            let newState: PronounceTranslationsUseCaseState = .loading(.group(translations: translations, currentTranslationIndex: translationIndex))
                            continuation.yield(newState)
                            continue
                            
                        case .playing:
                            let newState: PronounceTranslationsUseCaseState = .playing(.group(translations: translations, currentTranslationIndex: translationIndex))
                            self.state.value = newState
                            continuation.yield(newState)
                            continue
                            
                        case .failed:
                            self.state.value = .stopped
                            continuation.finish(throwing: NSError())
                            return

                        case .paused:
                            let newState: PronounceTranslationsUseCaseState = .paused(.group(translations: translations, currentTranslationIndex: translationIndex))
                            self.state.value = newState
                            continuation.yield(newState)
                            continuation.finish()
                            return
                        
                        case .stopped:
                            self.state.value = .stopped
                            continuation.yield(.stopped)
                            continuation.finish()
                            return
                        }
                    }
                }
                
                self.state.value = .finished
                continuation.yield(.finished)
                continuation.finish()
            }
        }
    }
    
    public func pause() -> Void {
        
        guard case .playing = state.value else {
            return
        }
        
        let _ = audioPlayer.pause()
    }
    
    public func stop() -> Void {
        
        let _ = audioPlayer.stop()
    }
}
