//
//  PronounceTextUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.09.2022.
//

import Foundation
import Combine

public final class PronounceTextUseCaseImpl: PronounceTextUseCase {

    // MARK: - Properties

    private let textToSpeechConverter: TextToSpeechConverter
    private let audioPlayer: AudioPlayer
    public var state = CurrentValueSubject<PronounceTextUseCaseState, Never>(.loading)

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

extension PronounceTextUseCaseImpl {

    public func pronounce(
        text: String,
        language: String
    ) -> AsyncThrowingStream<PronounceTextUseCaseState, Error> {

        return AsyncThrowingStream { continuation in
            
            Task {
                
                continuation.onTermination = { _ in
                    let _ = self.audioPlayer.stop()
                }
                
                state.value = .loading
                continuation.yield(.loading)
                
                let convertionResult = await self.textToSpeechConverter.convert(text: text, language: language)
                
                guard case .success(let data) = convertionResult else {
                
                    state.value = .finished
                    continuation.finish(throwing: .none)
                    return
                }
                
                state.value = .playing
                continuation.yield(.playing)
                
                let prepareResult = audioPlayer.prepare(
                    fileId: "file:\(text)/\(language)",
                    data: data
                )
                
                guard case .success = prepareResult else {
                    
                    state.value = .finished
                    continuation.finish(throwing: NSError())
                    return
                }

                
                for try await playerState in audioPlayer.playAndWaitForEnd() {
                    
                    switch playerState {
                        
                    case .paused, .stopped:
                        break
                        
                    default:
                        continue
                    }
                }
                
                state.value = .finished
                continuation.yield(.finished)
                continuation.finish()
            }
        }
    }
}
