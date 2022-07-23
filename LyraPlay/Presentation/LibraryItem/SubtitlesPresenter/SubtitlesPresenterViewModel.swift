//
//  SubtitlesPresenterViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.07.22.
//

import Foundation

// MARK: - Interfaces

public struct SubtitlesPresentationState {
    
    public var numberOfSentences: Int
    public var activeSentenceIndex: Int?
}

public struct SubtitlesPosition {
    
    public var sentenceIndex: Int
    public var timeMarkIndex: Int?
    
    public init(sentence: Int, timeMarkIndex: Int? = nil) {
        
        self.sentenceIndex = sentence
        self.timeMarkIndex = timeMarkIndex
    }
}

public protocol SubtitlesPresenterViewModelOutput {

    var state: Observable<SubtitlesPresentationState?> { get }
    
    func getSentenceViewModel(at index: Int) -> SentenceViewModel?
}

public protocol SubtitlesPresenterViewModelInput {

    func load() async
    
    func play(at: TimeInterval) async
    
    func pause() async
    
    func stop() async
}

public protocol SubtitlesPresenterViewModel: SubtitlesPresenterViewModelOutput, SubtitlesPresenterViewModelInput {
}

// MARK: - Implementations

extension DefaultSentenceViewModel {
    
    
}

public final class DefaultSubtitlesPresenterViewModel: SubtitlesPresenterViewModel {

    private let subtitles: Subtitles
    public let subtitlesIterator: SubtitlesIterator

    private var sentenceTimer: ActionTimer? = nil
    private var wordTimer: ActionTimer? = nil
    private var currentSpeed: Double = 1.0
    private var scheduler: Scheduler
    
    private var items: [DefaultSentenceViewModel] = []
    private var currentSentenceWithSelectedWord: Int?
    public let state: Observable<SubtitlesPresentationState?> = Observable(nil)
    
    public init(subtitles: Subtitles) {
        
        self.subtitles = subtitles
        
        self.subtitlesIterator = DefaultSubtitlesIterator(subtitles: subtitles)
        self.scheduler = DefaultScheduler(
            timeMarksIterator: subtitlesIterator,
            actionTimerFactory: DefaultActionTimerFactory()
        )
    }
}

// MARK: - Input

extension DefaultSubtitlesPresenterViewModel {

    public func load() async {
        
        var models: [DefaultSentenceViewModel] = []
        let sentences = subtitles.sentences
        let numberOfSentences = sentences.count
        
        let toggleWord: ToggleWordCallback = { [weak self] index, range in
            self?.toggleWord(index, range)
        }
        
        for index in 0..<numberOfSentences {
            
            let sentence = sentences[index]

            let text = sentence.text
            
            var sentenceModel = DefaultSentenceViewModel(
                id: index,
                text: text,
                toggleWord: toggleWord
            )
            
            sentenceModel.textComponents = sentence.components

            models.append(
                sentenceModel
            )
        }
        
        DispatchQueue.main.sync { [models] in
            
            self.items = models
            self.state.value = .init(
                numberOfSentences: self.items.count
            )
        }
        
    }
    
    private func updatePrevPosition() {

        guard let prevActiveSentence = self.state.value?.activeSentenceIndex else {
            return
        }
        
        let sentenceModel = getSentenceViewModel(at: prevActiveSentence)
        sentenceModel?.isActive.value = false
    }
    
    private func updateCurrentPosition(sentence: Int) {
        
        let sentenceModel = getSentenceViewModel(at: sentence)
        sentenceModel?.isActive.value = true
    }
    
    private func updatePosition() {
        
        let currentPosition = subtitlesIterator.currentPosition
        
        DispatchQueue.main.async {
        
            self.updatePrevPosition()
            
            if let currentSentence = currentPosition?.sentenceIndex {
                self.updateCurrentPosition(sentence: currentSentence)
            }

            var newState = self.state.value
            newState?.activeSentenceIndex = currentPosition?.sentenceIndex
            
            self.state.value = newState
        }
    }
    
    public func play(at time: TimeInterval) async {
        
        scheduler.start(at: time) { [weak self] time in
            
            guard let self = self else {
                return
            }

            self.updatePosition()
        }
    }
    
    public func pause() async {
        
        scheduler.pause()
    }
    
    public func stop() async {
        
        scheduler.stop()
    }
    
    private func deactivateWord(atSentence index: Int) {
        
        let item = items[index]
        let currentValue = item.selectedWordRange.value
        
        guard currentValue != nil else {
            return
        }
        
        item.selectedWordRange.value = nil
    }

    private func toggleWord(_ sentenceIndex: Int, _ tapRange: Range<String.Index>?) {
        
        DispatchQueue.main.async {
            
            guard sentenceIndex < self.items.count else {
                return
            }
            
            guard let tapRange = tapRange else {
                
                if let currentSentenceIndex = self.currentSentenceWithSelectedWord {
                    self.deactivateWord(atSentence: currentSentenceIndex)
                }
                return
            }
            
            if
                let currentSentenceIndex = self.currentSentenceWithSelectedWord,
                currentSentenceIndex != sentenceIndex
            {
                
                self.deactivateWord(atSentence: currentSentenceIndex)
            }
            
            let item = self.items[sentenceIndex]
            let selectedComponent = item.textComponents.first { item in item.range.overlaps(tapRange) }
            let currentRange = item.selectedWordRange.value
            
            guard
                let selectedType = selectedComponent?.type,
                selectedType == .word
            else {
                
                self.deactivateWord(atSentence: sentenceIndex)
                return
            }
            
            let selectedWordRange = selectedComponent?.range
            
            guard selectedWordRange != currentRange else {
                
                self.deactivateWord(atSentence: sentenceIndex)
                return
            }
            
            item.selectedWordRange.value = selectedWordRange
            self.currentSentenceWithSelectedWord = sentenceIndex
        }
    }
    
    public func getSentenceViewModel(at index: Int) -> SentenceViewModel? {
        
        guard index < items.count else {
            return nil
        }
        
        return items[index]
    }
}
