//
//  CurrentPlayerStateDetailsViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

import Foundation
import Combine

public final class CurrentPlayerStateDetailsViewModelImpl: CurrentPlayerStateDetailsViewModel {
    
    
    // MARK: - Properties
    
    private weak var delegate: CurrentPlayerStateDetailsViewModelDelegate?
    
    private let playMediaUseCase: PlayMediaWithInfoUseCase
    
    private let subtitlesPresenterViewModelFactory: SubtitlesPresenterViewModelFactory
    
    public let state = CurrentValueSubject<CurrentPlayerStateDetailsViewModelState, Never>(.loading)
    
    private var observers = Set<AnyCancellable>()
    
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
    
    // MARK: - Methods
    
    private func startUpdatingSlider() {
        
        timerObserver = Timer.publish(
            every: 0.8,
            on: .main,
            in: .default
        ).sink { [weak self] _ in
            
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
    
    private func updateLoadedState(
        playerState: PlayMediaWithInfoUseCasePlayerState,
        mediaInfo: MediaInfo
    ) {
        
        var subtitlesPresenterViewModel: SubtitlesPresenterViewModel?
        
        if let subtitlesState = playMediaUseCase.subtitlesState.value {
            
            subtitlesPresenterViewModel = subtitlesPresenterViewModelFactory.make(subtitles: subtitlesState.subtitles)
            currentSubtitles = subtitlesState.subtitles
            
            subtitlesPresenterViewModel?.update(position: subtitlesState.position)
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
    
    private func updateState(_ newState: PlayMediaWithInfoUseCaseState) {
        
        switch newState {
            
        case .noActiveSession:
            state.value = .notActive
            
        case .activeSession(_, let loadState):
            
            switch loadState {
                
            case .loading:
                state.value = .loading
                
            case .loadFailed:
                state.value = .notActive
                
            case .loaded(let playerState, let mediaInfo):
                updateLoadedState(
                    playerState: playerState,
                    mediaInfo: mediaInfo
                )
            }
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
        
        subtitlesPresenterViewModel.update(position: subtitlesState.position)
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
        
        print("Implement me")
    }
    
    public func moveBackward() {
        print("Implement me")
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

// MARK: - Output Methods

extension CurrentPlayerStateDetailsViewModelImpl {
    
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
