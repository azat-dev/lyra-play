//
//  ProvideTranslationsToPlayUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.08.2022.
//

import Foundation

// MARK: - Interfaces

public enum TranslationsToPlayData: Equatable {

    case single(translation: SubtitlesTranslationItem)
    case groupAfterSentence(items: [SubtitlesTranslationItem])
}

public struct TranslationsToPlay {

    public var time: TimeInterval
    public var data: TranslationsToPlayData

    public init(
        time: TimeInterval,
        data: TranslationsToPlayData
    ) {

        self.time = time
        self.data = data
    }
}

public protocol ProvideTranslationsToPlayUseCaseInput {

    func prepare(params: AdvancedPlayerSession) async -> Void

    func beginNextExecution(from time: TimeInterval?) -> TimeInterval?

    func getTimeOfNextEvent() -> TimeInterval?

    func moveToNextEvent() -> TimeInterval?
}

public protocol ProvideTranslationsToPlayUseCaseOutput {

    var lastEventTime: TimeInterval? { get }

    var currentItem: TranslationsToPlay? { get }
}

public protocol ProvideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCaseOutput, ProvideTranslationsToPlayUseCaseInput {
}

// MARK: - Implementations

public final class DefaultProvideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase {

    
    typealias QueueItem = (sentenceIndex: Int, item: TranslationsToPlay)
    
    // MARK: - Properties

    private let provideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCase

    public let lastEventTime: TimeInterval? = nil
    
    public let currentItem: TranslationsToPlay? = nil
    
    private var itemsQueue = [QueueItem]()
    
    private var subtitles: Subtitles? = nil

    // MARK: - Initializers

    public init(provideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCase) {

        self.provideTranslationsForSubtitlesUseCase = provideTranslationsForSubtitlesUseCase
    }
}

// MARK: - Input methods

extension DefaultProvideTranslationsToPlayUseCase {

    private func prepareNextItems() async {
        
        guard let subtitles = subtitles else {
            return
        }
        
        let lastSentenceIndex = itemsQueue.last?.sentenceIndex ?? -1
        let nextSentenceIndex = lastSentenceIndex + 1
        
        guard nextSentenceIndex < subtitles.sentences.count else {
            return
        }
        
        let sentenceTranslations = await provideTranslationsForSubtitlesUseCase.getTranslations(sentenceIndex: nextSentenceIndex)
        
        let sentence = subtitles.sentences[nextSentenceIndex]
    }
    
    public func prepare(params: AdvancedPlayerSession) async -> Void {

        itemsQueue = [QueueItem]()
        subtitles = params.subtitles
        
        await provideTranslationsForSubtitlesUseCase.prepare(options: params)
        
        await prepareNextItems()
    }

    public func beginNextExecution(from time: TimeInterval?) -> TimeInterval? {

        fatalError("Not implemented")
    }

    public func getTimeOfNextEvent() -> TimeInterval? {

        guard itemsQueue.count >= 2 else {
            
            return nil
        }
        
        return itemsQueue[1].item.time
    }

    public func moveToNextEvent() -> TimeInterval? {

        itemsQueue.removeFirst()
        
        if itemsQueue.count < 3 {
            
//            prepareNextItems()
        }
        
        return itemsQueue.first?.item.time
    }
}
