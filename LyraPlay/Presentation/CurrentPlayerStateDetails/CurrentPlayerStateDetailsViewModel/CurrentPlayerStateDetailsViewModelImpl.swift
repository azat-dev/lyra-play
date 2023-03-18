//
//  CurrentPlayerStateDetailsViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

import Foundation
import Combine
import UIKit

public final class CurrentPlayerStateDetailsViewModelImpl: CurrentPlayerStateDetailsViewModel {
    
    private static let playBackTimeStep: TimeInterval = 5
    
    // MARK: - Properties
    
    private weak var delegate: CurrentPlayerStateDetailsViewModelDelegate?
    
    private let playMediaUseCase: PlayMediaWithInfoUseCase
    
    private let subtitlesPresenterViewModelFactory: SubtitlesPresenterViewModelFactory
    
    public let state = CurrentValueSubject<CurrentPlayerStateDetailsViewModelState, Never>(.loading)
    
    private var observers = Set<AnyCancellable>()
    
    private var loadStateObserver: AnyCancellable?
    
    private var playerStateObserver: AnyCancellable?
    
    private var currentSubtitles: Subtitles?

    public var sliderValue: CurrentValueSubject<Float, Never>
    
    public var duration: Float {
        return Float(playMediaUseCase.duration)
    }
    
    private var timerObserver: AnyCancellable?
    
    // MARK: - Initializers
    
    public init(
        delegate: CurrentPlayerStateDetailsViewModelDelegate,
        playMediaUseCase: PlayMediaWithInfoUseCase,
        subtitlesPresenterViewModelFactory: SubtitlesPresenterViewModelFactory
    ) {
        
        self.delegate = delegate
        self.playMediaUseCase = playMediaUseCase
        self.subtitlesPresenterViewModelFactory = subtitlesPresenterViewModelFactory
        self.sliderValue = .init(Float(playMediaUseCase.currentTime))
        
        bind(to: playMediaUseCase)
    }
    
    deinit {
        observers.removeAll()
        playerStateObserver = nil
        loadStateObserver = nil
    }
    
    // MARK: - Methods
    
    private func startUpdatingSlider() {
        
        timerObserver = Timer.publish(
            every: 0.8,
            on: .main,
            in: .default
        )
        .autoconnect()
        .sink { [weak self] _ in
            
            guard let self = self else {
                return
            }
            
            self.sliderValue.value = Float(self.playMediaUseCase.currentTime)
        }
    }
    
    private func stopUpdatingSlider() {
        
        timerObserver = nil
    }
    
    private func updateTimer(isPlaying: Bool) {
        
        guard isPlaying else {
            stopUpdatingSlider()
            return
        }
        
        startUpdatingSlider()
    }
    
    private func updatePlayerState(
        playerState: PlayMediaWithInfoUseCasePlayerState,
        mediaInfo: MediaInfo
    ) {
        
        var subtitlesPresenterViewModel: SubtitlesPresenterViewModel?
        
        if let subtitlesState = playMediaUseCase.subtitlesState.value {
            
            subtitlesPresenterViewModel = subtitlesPresenterViewModelFactory.make(
                subtitles: subtitlesState.subtitles,
                timeSlots: subtitlesState.timeSlots,
                delegate: self
            )
            currentSubtitles = subtitlesState.subtitles
            
            subtitlesPresenterViewModel?.update(position: subtitlesState.timeSlot)
        }
        
        let isPlaying = playerState.isPlaying
        
        updateTimer(isPlaying: isPlaying)
        
        state.value = .active(
            data: .init(
                title: mediaInfo.title,
                subtitle: mediaInfo.artist ?? "",
                coverImage: mediaInfo.coverImage,
                isPlaying: isPlaying,
                subtitlesPresenterViewModel: subtitlesPresenterViewModel
            )
        )
    }
    
    private func pipePlayerState(
        from state: CurrentValueSubject<PlayMediaWithInfoUseCasePlayerState, Never>,
        withMediaInfo mediaInfo: MediaInfo
    ) {
        
        playerStateObserver = state.sink { [weak self] newState in
            
            self?.updatePlayerState(
                playerState: newState,
                mediaInfo: mediaInfo
            )
        }
    }
    
    private func pipeLoadState(from state: CurrentValueSubject<PlayMediaWithInfoUseCaseLoadState, Never>) {
        
        loadStateObserver = state.sink { [weak self] newState in
            
            guard let self = self else {
                return
            }
            
            switch newState {
                
            case .loading:
                state.value = .loading
                
            case .loadFailed:
                state.value = .loadFailed
                
            case .loaded(let sourcePlayerState, let mediaInfo):
                self.pipePlayerState(from: sourcePlayerState, withMediaInfo: mediaInfo)
            }
        }
    }
    
    private func updateState(_ newState: PlayMediaWithInfoUseCaseState) {
        
        loadStateObserver = nil
        playerStateObserver = nil
        
        switch newState {
            
        case .noActiveSession:
            state.value = .notActive
            
        case .activeSession(_, let sourceLoadState):
            
            pipeLoadState(from: sourceLoadState)
        }
    }
    
    private func updateSubtitlesPresenter(subtitlesState: SubtitlesState?) {
        
        guard case .active(let data) = state.value else {
            return
        }
        
        guard let subtitlesPresenterViewModel = data.subtitlesPresenterViewModel else {
            return
        }
        
        guard let subtitlesState = subtitlesState else {
            
            var newData = data
            newData.subtitlesPresenterViewModel = nil
            
            state.value = .active(data: newData)
            return
        }
        
        subtitlesPresenterViewModel.update(position: subtitlesState.timeSlot)
    }
    
    private func bind(to playMediaUseCase: PlayMediaWithInfoUseCase) {
        
        observers.removeAll()
        
        playMediaUseCase.state
            .sink { [weak self] state in
                self?.updateState(state)
            }.store(in: &observers)
        
        playMediaUseCase.subtitlesState
            .sink { [weak self] subtitlesState in
                
                self?.updateSubtitlesPresenter(subtitlesState: subtitlesState)
            }.store(in: &observers)
    }
    
    public func moveForward() {

        let nextTime = min(playMediaUseCase.currentTime + Self.playBackTimeStep, playMediaUseCase.duration)
        playMediaUseCase.setTime(nextTime)
    }
    
    public func moveBackward() {
        
        let nextTime = max(playMediaUseCase.currentTime - Self.playBackTimeStep, 0)
        playMediaUseCase.setTime(nextTime)
    }
    
    public func seek(time: Float) {
        
        sliderValue.value = time
    }
    
    public func startSeeking() {
        stopUpdatingSlider()
    }
    
    public func endSeeking(time: Float) {
        
        playMediaUseCase.setTime(TimeInterval(time))
        startUpdatingSlider()
    }
}

// MARK: - Input Methods

extension CurrentPlayerStateDetailsViewModelImpl {
    
    public func togglePlay() {
        
        let _ = playMediaUseCase.togglePlay()
    }
    
    public func dispose() {
        
        delegate?.currentPlayerStateDetailsViewModelDidDispose()
    }
}

extension CurrentPlayerStateDetailsViewModelImpl: SubtitlesPresenterViewModelDelegate {
    
    public func subtitlesPresenterViewModelDidTapWord(text word: String) {

        let encodedText = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "googletranslate://?sl=en&tl=ru&text=\(encodedText)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Helpers

fileprivate extension PlayMediaWithInfoUseCasePlayerState {
    
    var isPlaying: Bool {
        
        switch self {
            
        case .playing, .pronouncingTranslations:
            return true
            
        default:
            return false
        }
    }
}
