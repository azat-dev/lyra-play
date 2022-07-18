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
    
    public var sentence: Int
    public var word: Int?
    
    public init(sentence: Int, word: Int? = nil) {
        
        self.sentence = sentence
        self.word = word
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

public final class DefaultSubtitlesPresenterViewModel: SubtitlesPresenterViewModel {

    private let subtitles: Subtitles
    public let subtitlesIterator: SubtitlesIterator

    private var sentenceTimer: ActionTimer? = nil
    private var wordTimer: ActionTimer? = nil
    private var currentSpeed: Double = 1.0
    private var scheduler: Scheduler
    
    private var items: [DefaultSentenceViewModel] = []
    public let state: Observable<SubtitlesPresentationState?> = Observable(nil)
    
    public init(
        subtitles: Subtitles
    ) {
        
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
            
            models.append(
                .init(
                    id: index,
                    text: sentence.text.getText(),
                    toggleWord: toggleWord
                )
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
            
            if let currentSentence = currentPosition?.sentence {
                self.updateCurrentPosition(sentence: currentSentence)
            }

            var newState = self.state.value
            newState?.activeSentenceIndex = currentPosition?.sentence
            
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
    
    private func toggleWord(_ sentenceIndex: Int, _ tapRange: Range<String.Index>) {
        
    }
    
    public func getSentenceViewModel(at index: Int) -> SentenceViewModel? {
    
        
        guard index < items.count else {
            return nil
        }
        
        return items[index]
    }
}
