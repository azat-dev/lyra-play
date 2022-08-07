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

    func beginNextExecution(from: TimeInterval) -> TimeInterval?

    func getTimeOfNextEvent() -> TimeInterval?

    func moveToNextEvent() -> TimeInterval?
}

public protocol ProvideTranslationsToPlayUseCaseOutput {

    var lastEventTime: TimeInterval? { get }

    var currentItem: TranslationsToPlay? { get }
}

public protocol ProvideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCaseOutput, ProvideTranslationsToPlayUseCaseInput, TimeLineIterator {
}

// MARK: - Implementations

public final class DefaultProvideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase {

    private typealias SentenceIndex = Int
    
    private struct QueueItem {
        
        var sentenceIndex: SentenceIndex
        var item: TranslationsToPlay
    }
    
    
    
    // MARK: - Properties

    private let minNumberOfItemsToQueue = 3
    
    private let provideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCase

    public var lastEventTime: TimeInterval? { currentItem?.time }
    
    public var currentItem: TranslationsToPlay? = nil
    
    private var queueItems = [QueueItem]()
    
    private var subtitles: Subtitles? = nil
    
    private var subtitlesTimeSlots: [SentenceIndex: [SubtitlesTimeSlot]]? = nil

    // MARK: - Initializers

    public init(provideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCase) {

        self.provideTranslationsForSubtitlesUseCase = provideTranslationsForSubtitlesUseCase
    }
}

// MARK: - Input methods

extension DefaultProvideTranslationsToPlayUseCase {

    private static func getTimeSlotsBySentences(timeSlots: [SubtitlesTimeSlot]) -> [SentenceIndex: [SubtitlesTimeSlot]] {
        
        var result = [SentenceIndex: [SubtitlesTimeSlot]]()
        
        var currentSentenceIndex: Int?
        var lastSentenceItems = [SubtitlesTimeSlot]()
        
        
        let appendSentenceItemsToResult = { () -> Void in
            
            guard
                let currentSentenceIndex = currentSentenceIndex,
                !lastSentenceItems.isEmpty
            else {
                return
            }

            result[currentSentenceIndex] = lastSentenceItems
        }
        
        let startNewSentence = { (newSentenceIndex: Int) -> Void in
            
            currentSentenceIndex  = newSentenceIndex
            lastSentenceItems = []
        }
        
        
        for timeSlot in timeSlots {
            
            guard let position = timeSlot.subtitlesPosition else {
            
                appendSentenceItemsToResult()
                
                currentSentenceIndex = nil
                lastSentenceItems = []
                continue
            }

            if currentSentenceIndex != position.sentenceIndex {
                
                appendSentenceItemsToResult()
                startNewSentence(position.sentenceIndex)
            }
            
            lastSentenceItems.append(timeSlot)
        }
        
        if !lastSentenceItems.isEmpty {
            
            appendSentenceItemsToResult()
        }
        
        return result
    }
    
    private func appendSingleTranslation(sentenceIndex: Int, time: TimeInterval, translation: SubtitlesTranslationItem) {
        
        queueItems.append(
            .init(
                sentenceIndex: sentenceIndex,
                item: .init(
                    time: time,
                    data: .single(translation: translation)
                )
            )
        )
    }
    
    private func appendGroupedTranslations(sentenceIndex: Int, time: TimeInterval, items: [SubtitlesTranslationItem]) {
        
        guard !items.isEmpty else {
            return
        }
        
        queueItems.append(
            .init(
                sentenceIndex: sentenceIndex,
                item: .init(
                    time: time,
                    data: .groupAfterSentence(items: items)
                )
            )
        )
    }
    
    private func prepareNextItems() async {
        
        guard
            let subtitles = subtitles,
            let subtitlesTimeSlots = subtitlesTimeSlots
        else {
            return
        }
        
        let lastSentenceIndex = queueItems.last?.sentenceIndex ?? -1
        let sentenceIndex = lastSentenceIndex + 1
        
        guard sentenceIndex < subtitles.sentences.count else {
            return
        }
        
        let translations = await provideTranslationsForSubtitlesUseCase.getTranslations(sentenceIndex: sentenceIndex)
        
        let timeSlotsForSentence = subtitlesTimeSlots[sentenceIndex, default: []]
        guard
            let sentenceTimeRange = timeSlotsForSentence.last?.timeRange
        else {
            return
        }
        
        var groupedTranslations = [SubtitlesTranslationItem]()

        let sentence = subtitles.sentences[sentenceIndex]
        let timeMarks = sentence.timeMarks ?? []
        
        for translation in translations {
            
            let boundedTimeMarkIndex = timeMarks.firstIndex { $0.range.overlaps(translation.textRange) }
            
            if let boundedTimeMarkIndex = boundedTimeMarkIndex {
                
                let timeSlot = timeSlotsForSentence.first { $0.subtitlesPosition?.timeMarkIndex == boundedTimeMarkIndex }

                guard let timeSlot = timeSlot else {
                    continue
                }
                
                appendSingleTranslation(
                    sentenceIndex: sentenceIndex,
                    time: timeSlot.timeRange.upperBound,
                    translation: translation.translation
                )
                continue
            }
            
            
            let isTranslationUnique = !groupedTranslations.contains {
                $0.translationId == translation.translation.translationId &&
                $0.dictionaryItemId == translation.translation.dictionaryItemId
            }
            
            guard isTranslationUnique else {
                continue
            }
            
            groupedTranslations.append(translation.translation)
        }

        appendGroupedTranslations(
            sentenceIndex: sentenceIndex,
            time: sentenceTimeRange.upperBound,
            items: groupedTranslations
        )
        
        if queueItems.count < minNumberOfItemsToQueue {
            
            await prepareNextItems()
        }
    }
    
    public func prepare(params: AdvancedPlayerSession) async -> Void {

        queueItems = [QueueItem]()
        subtitles = params.subtitles
        
        // FIXME: Make timeSlots dependency
        let parser = SubtitlesTimeSlotsParser()
        let timeSlots = parser.parse(from: params.subtitles)
        subtitlesTimeSlots = Self.getTimeSlotsBySentences(timeSlots: timeSlots)
        
        await provideTranslationsForSubtitlesUseCase.prepare(options: params)
        
        await prepareNextItems()
    }

    public func getTimeOfNextEvent() -> TimeInterval? {

        return queueItems.first?.item.time
    }

    public func moveToNextEvent() -> TimeInterval? {

        if queueItems.count < minNumberOfItemsToQueue {
            
            let semaphore = DispatchSemaphore(value: 0)
            
            Task(priority: .userInitiated) {
                
                await prepareNextItems()
                semaphore.signal()
            }
            
            semaphore.wait()
        }
        
        
        let droppedItem = queueItems.removeFirst()
        currentItem = droppedItem.item
        
        return lastEventTime
    }
    
    public func beginNextExecution(from: TimeInterval) -> TimeInterval? {
        fatalError("Not implemented")
    }
}
