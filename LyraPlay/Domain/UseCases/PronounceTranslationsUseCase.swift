//
//  PronounceTranslationsUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.08.2022.
//

import Foundation
import Combine
import AVFAudio

// MARK: - Interfaces

public enum PronounceTranslationsUseCaseStateData: Equatable {
    
    case single(translation: SubtitlesTranslationItem)
    case group(translations: [SubtitlesTranslationItem], currentTranslationIndex: Int?)
}

public enum PronounceTranslationsUseCaseState: Equatable {
    
    case loading(PronounceTranslationsUseCaseStateData)
    case playing(PronounceTranslationsUseCaseStateData)
    case paused(PronounceTranslationsUseCaseStateData)
    case stopped
    case finished
}

public protocol PronounceTranslationsUseCaseInput {
    
    func pronounceSingle(translation: SubtitlesTranslationItem) -> AsyncThrowingStream<PronounceTranslationsUseCaseState, Error>
    
    func pronounceGroup(translations: [SubtitlesTranslationItem]) -> AsyncThrowingStream<PronounceTranslationsUseCaseState, Error>
    
    func pause() -> Void
    
    func stop() -> Void
}

public protocol PronounceTranslationsUseCaseOutput {
    
    var state: CurrentValueSubject<PronounceTranslationsUseCaseState, Never> { get }
}

public protocol PronounceTranslationsUseCase: PronounceTranslationsUseCaseOutput, PronounceTranslationsUseCaseInput {
}

// MARK: - Implementations

public final class DefaultPronounceTranslationsUseCase: PronounceTranslationsUseCase {
    
    // MARK: - Properties
    
    private let textToSpeechConverter: TextToSpeechConverter
    private let audioPlayer: AudioPlayer
    
    public let state = CurrentValueSubject<PronounceTranslationsUseCaseState, Never>(.stopped)
    
    // MARK: - Initializers
    
    public init(
        textToSpeechConverter: TextToSpeechConverter,
        audioPlayer: AudioPlayer
    ) {
        
        self.textToSpeechConverter = textToSpeechConverter
        self.audioPlayer = audioPlayer
    }
}

// MARK: - Input methods

extension DefaultPronounceTranslationsUseCase {
    
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
                        continue
                        
                    case .failed:
                        continuation.finish(throwing: NSError())
                        return

                    case .playing:
                        continuation.yield(.playing(.single(translation: translation)))
                    
                    case .paused:
                        continuation.yield(.paused(.single(translation: translation)))
                        continuation.finish()
                        return
                    
                    case .stopped:
                        
                        continuation.yield(.stopped)
                        continuation.finish()
                        return
                    
                    case .finished:
                        
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
                        case .converting, .loading, .finished, .playing:
                            continue
                            
                        case .failed:
                            continuation.finish(throwing: NSError())
                            return

                        case .paused:
                            continuation.yield(.paused(.group(translations: translations, currentTranslationIndex: translationIndex)))
                            continuation.finish()
                            return
                        
                        case .stopped:
                            
                            continuation.yield(.stopped)
                            continuation.finish()
                            return
                        }
                    }
                }
                
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
