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

    public let state = CurrentValueSubject<CurrentPlayerStateDetailsViewModelState, Never>(.loading)
    
    private var observers = Set<AnyCancellable>()

    // MARK: - Initializers

    public init(
        delegate: CurrentPlayerStateDetailsViewModelDelegate,
        playMediaUseCase: PlayMediaWithInfoUseCase
    ) {

        self.delegate = delegate
        self.playMediaUseCase = playMediaUseCase
        
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
                
            case .loaded(let playerState, _, let mediaInfo):

                state.value = .active(
                    data: .init(
                        title: mediaInfo.title,
                        subtitle: mediaInfo.artist ?? "",
                        coverImage: mediaInfo.coverImage,
                        isPlaying: playerState.isPlaying
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
