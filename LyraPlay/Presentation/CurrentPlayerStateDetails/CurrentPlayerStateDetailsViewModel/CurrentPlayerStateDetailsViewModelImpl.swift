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
                
            case .loaded(let playerState, let subtitlesState, let mediaInfo):

                var subtitlesPresenterViewModel: SubtitlesPresenterViewModel?
                
                if let subtitlesState = subtitlesState {
                    
                    if case .active(let prevState) = state.value {
                        subtitlesPresenterViewModel = prevState.subtitlesPresenterViewModel
                    }
                    
                    if subtitlesPresenterViewModel == nil || currentSubtitles != subtitlesState.subtitles {
                        subtitlesPresenterViewModel = subtitlesPresenterViewModelFactory.create(subtitles: subtitlesState.subtitles)
                    }
                    
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
        }
    }
    
    private func bind(to playMediaUseCase: PlayMediaWithInfoUseCase) {
        
        playMediaUseCase.state.publisher
            .sink { [weak self] state in
                self?.updateState(state)
            }.store(in: &observers)
    }
}

// MARK: - Input Methods

extension CurrentPlayerStateDetailsViewModelImpl {

    public func togglePlay() {

        playMediaUseCase.togglePlay()
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
