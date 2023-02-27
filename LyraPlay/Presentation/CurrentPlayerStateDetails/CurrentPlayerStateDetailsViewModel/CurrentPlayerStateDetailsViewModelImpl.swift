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

    // MARK: - Initializers

    public init(
        delegate: CurrentPlayerStateDetailsViewModelDelegate,
        playMediaUseCase: PlayMediaWithInfoUseCase,
        subtitlesPresenterViewModelFactory: SubtitlesPresenterViewModelFactory
    ) {

        self.delegate = delegate
        self.playMediaUseCase = playMediaUseCase
        self.subtitlesPresenterViewModelFactory = subtitlesPresenterViewModelFactory
        
        bind(to: playMediaUseCase)
    }
    
    // MARK: - Methods
    
    private func didLoad(playerState: PlayMediaWithInfoUseCasePlayerState, mediaInfo: MediaInfo) {
        
        var subtitlesPresenterViewModel: SubtitlesPresenterViewModel?
        
        if let subtitlesState = playMediaUseCase.subtitlesState.value {
            
            subtitlesPresenterViewModel = subtitlesPresenterViewModelFactory.make(subtitles: subtitlesState.subtitles)
            currentSubtitles = subtitlesState.subtitles
            
            subtitlesPresenterViewModel?.update(position: subtitlesState.position)
        }
        
        state.value = .active(
            data: .init(
                title: mediaInfo.title,
                subtitle: mediaInfo.artist ?? "",
                coverImage: mediaInfo.coverImage,
                isPlaying: playerState.isPlaying,
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
                didLoad(playerState: playerState, mediaInfo: mediaInfo)
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
