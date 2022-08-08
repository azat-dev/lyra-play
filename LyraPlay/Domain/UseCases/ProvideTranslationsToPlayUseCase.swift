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

    private let minNumberOfItemsToQueue: Int
    
    private let provideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCase

    public var lastEventTime: TimeInterval? { currentItem?.time }
    
    public var currentItem: TranslationsToPlay? = nil
    
    private var lastPreparedSentenceIndex: Int?
    
    private var queueItems = [QueueItem]()
    
    private var subtitles: Subtitles!
    
    private var subtitlesTimeSlots: [SentenceIndex: [SubtitlesTimeSlot]]!

    // MARK: - Initializers

    public init(
        provideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCase,
        minNumberOfItemsToQueue: Int = 3
    ) {

        self.minNumberOfItemsToQueue = minNumberOfItemsToQueue
        self.provideTranslationsForSubtitlesUseCase = provideTranslationsForSubtitlesUseCase
    }
}

// MARK: - Input methods

extension DefaultProvideTranslationsToPlayUseCase {

    private static func groupTimeSlotsBySentences(timeSlots: [SubtitlesTimeSlot]) -> [SentenceIndex: [SubtitlesTimeSlot]] {
        
        var result = [SentenceIndex: [SubtitlesTimeSlot]]()
        
        for timeSlot in timeSlots {
            
            guard let sentenceIndex = timeSlot.subtitlesPosition?.sentenceIndex else {
                continue
            }
            
            var newItems = result[sentenceIndex, default: []]
            newItems.append(timeSlot)
            result[sentenceIndex] = newItems
        }
        
        return result
    }
    

    private func getNextItems(sentenceIndex: Int) async -> [QueueItem] {
        
        var items = [QueueItem]()
        
        guard sentenceIndex < subtitles.sentences.count else {
            return items
        }
        
        let translations = await provideTranslationsForSubtitlesUseCase.getTranslations(sentenceIndex: sentenceIndex)
        
        let timeSlotsForSentence = subtitlesTimeSlots[sentenceIndex, default: []]
        guard
            let sentenceTimeRange = timeSlotsForSentence.last?.timeRange
        else {
            return items
        }
        
        var groupedTranslations = [SubtitlesTranslationItem]()

        let sentence = subtitles.sentences[sentenceIndex]
        let timeMarks = sentence.timeMarks ?? []
        
        for translation in translations {
            
            let boundedTimeMarkIndex = timeMarks.lastIndex { $0.range.overlaps(translation.textRange) }
            
            if let boundedTimeMarkIndex = boundedTimeMarkIndex {
                
                let boundedTimeMark = timeMarks[boundedTimeMarkIndex]
                
                if boundedTimeMark.range.upperBound < translation.textRange.upperBound {
                
                    groupedTranslations.append(translation.translation)
                    continue
                }
                
                let timeSlot = timeSlotsForSentence.first { $0.subtitlesPosition?.timeMarkIndex == boundedTimeMarkIndex }

                guard let timeSlot = timeSlot else {
                    continue
                }
                
                items.append(
                    .init(
                        sentenceIndex: sentenceIndex,
                        item: .init(
                            time: timeSlot.timeRange.upperBound,
                            data: .single(translation: translation.translation)
                        )
                    )
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
        
        guard !groupedTranslations.isEmpty else {

            return items
        }
        
        
        items.append(
            .init(
                sentenceIndex: sentenceIndex,
                item: .init(
                    time: sentenceTimeRange.upperBound,
                    data: .groupAfterSentence(items: groupedTranslations)
                )
            )
        )
        
        return items
    }
    
    private func prepareNextItems() async {
        
        let sentenceIndex = (lastPreparedSentenceIndex ?? -1) + 1
        
        guard sentenceIndex < subtitles.sentences.count else {
            return
        }
        
        lastPreparedSentenceIndex = sentenceIndex
        let nextItems = await getNextItems(sentenceIndex: sentenceIndex)

        queueItems.append(contentsOf: nextItems)
        
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
        subtitlesTimeSlots = Self.groupTimeSlotsBySentences(timeSlots: timeSlots)
        
        await provideTranslationsForSubtitlesUseCase.prepare(options: params)
        
        await prepareNextItems()
    }
    
    private func prepareItemsIfNeeded() {
        
        guard queueItems.count < minNumberOfItemsToQueue else {
            return
        }

        // FIXME: Remove semaphore
        let semaphore = DispatchSemaphore(value: 0)
        
        Task(priority: .userInitiated) {
            
            defer { semaphore.signal() }
            await prepareNextItems()
        }
        
        semaphore.wait()
    }

    public func getTimeOfNextEvent() -> TimeInterval? {

        prepareItemsIfNeeded()
        return queueItems.first?.item.time
    }

    public func moveToNextEvent() -> TimeInterval? {

        prepareItemsIfNeeded()
        let droppedItem = queueItems.removeFirst()
        currentItem = droppedItem.item
        
        return lastEventTime
    }
    
    private func findItems(for time: TimeInterval) async -> (sentenceIndex: Int, items: [QueueItem], lastItemIndex: Int)? {
        
        let numberOfSentences = subtitles.sentences.count
        
        for sentenceIndex in stride(from: numberOfSentences - 1, through: 0, by: -1) {
    
            let timeSlots = subtitlesTimeSlots[sentenceIndex, default: []]
            let timeSlotIndex = timeSlots.lastIndex { $0.timeRange.contains(time) || $0.timeRange.upperBound <= time }
            
            guard timeSlotIndex != nil else {
                continue
            }
            
            let items = await getNextItems(sentenceIndex: sentenceIndex)
            
            guard let lastIndex = items.lastIndex (where: { $0.item.time <= time }) else {
                continue
            }
            
            return (sentenceIndex, items, lastIndex)
        }

        return nil
    }
    
    private func resetState() {
        
        currentItem = nil
        queueItems = []
        lastPreparedSentenceIndex = nil
    }
    
    public func beginNextExecution(from time: TimeInterval) -> TimeInterval? {
        
        // FIXME: Remove semaphore
        let semaphore = DispatchSemaphore(value: 0)

        Task(priority: .userInitiated) {

            defer { semaphore.signal() }
            
            guard let foundItemData = await findItems(for: time) else {
                
                resetState()
                return
            }
            
            var nextItems = foundItemData.items
            let sentenceIndex = foundItemData.sentenceIndex

            nextItems.removeFirst(foundItemData.lastItemIndex)
            
            if nextItems.isEmpty {

                currentItem = nil
            } else {

                currentItem = nextItems.removeFirst().item
            }
            
            queueItems = nextItems
            lastPreparedSentenceIndex = sentenceIndex
        }
        
        semaphore.wait()
        prepareItemsIfNeeded()
        
        return lastEventTime
    }
}
