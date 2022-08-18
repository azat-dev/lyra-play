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

public struct TranslationsToPlay: Equatable {
    
    public var position: SubtitlesPosition
    public var data: TranslationsToPlayData
    
    public init(
        position: SubtitlesPosition,
        data: TranslationsToPlayData
    ) {
        
        self.position = position
        self.data = data
    }
}
public protocol ProvideTranslationsToPlayUseCaseInput {
    
    func prepare(params: AdvancedPlayerSession) async -> Void
}

public protocol ProvideTranslationsToPlayUseCaseOutput {
    
    func getTranslationsToPlay(for position: SubtitlesPosition) -> TranslationsToPlayData?
}

public protocol ProvideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCaseOutput, ProvideTranslationsToPlayUseCaseInput {
}

// MARK: - Implementations

public final class DefaultProvideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase {
    
    private typealias SentenceIndex = Int
    
    // MARK: - Properties
    
    private let provideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCase

    private var subtitles: Subtitles!
    
    private var subtitlesTimeSlots: [SentenceIndex: [SubtitlesTimeSlot]]!
    
    private var items = [SubtitlesPosition: TranslationsToPlay]()
    
    // MARK: - Initializers
    
    public init(
        provideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCase
    ) {
        
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
    
    private func getGroupedTranslations(sentenceIndex: Int) async -> [TranslationsToPlay] {
        
        var items = [TranslationsToPlay]()
        
        guard sentenceIndex < subtitles.sentences.count else {
            return items
        }
        
        let translations = await provideTranslationsForSubtitlesUseCase.getTranslations(sentenceIndex: sentenceIndex)
        
        let timeSlotsForSentence = subtitlesTimeSlots[sentenceIndex, default: []]
        
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
                
                guard
                    let timeSlot = timeSlot,
                    let position = timeSlot.subtitlesPosition
                else {
                    continue
                }
                
                items.append(
                    .init(
                        position: position,
                        data: .single(translation: translation.translation)
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
                position: .sentence(sentenceIndex),
                data: .groupAfterSentence(items: groupedTranslations)
            )
        )
        
        return items
    }
    
    public func prepare(params: AdvancedPlayerSession) async -> Void {
        
        subtitles = params.subtitles
        
        await provideTranslationsForSubtitlesUseCase.prepare(options: params)
        
        // FIXME: Make timeSlots dependency
        let parser = SubtitlesTimeSlotsParser()
        let timeSlots = parser.parse(from: params.subtitles)
        subtitlesTimeSlots = Self.groupTimeSlotsBySentences(timeSlots: timeSlots)
        
        let numberOfSentences = params.subtitles.sentences.count
        
        for sentenceIndex in 0..<numberOfSentences {
            
            let translations = await getGroupedTranslations(sentenceIndex: sentenceIndex)
        
            if Task.isCancelled {
                return
            }
            
            translations.forEach { translation in
                items[translation.position] = translation
            }
        }
    }
    
    public func getTranslationsToPlay(for position: SubtitlesPosition) -> TranslationsToPlayData? {
        
        return items[position]?.data
    }
}
