//
//  CurrentPlayerStateViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation
import Combine

public final class CurrentPlayerStateViewModelImpl: CurrentPlayerStateViewModel {

    // MARK: - Properties

    private weak var delegate: CurrentPlayerStateViewModelDelegate?
    
    private let playMediaUseCase: PlayMediaWithInfoUseCase
    public var state = CurrentValueSubject<CurrentPlayerStateViewModelState, Never>(.loading)
    
    private var observers = Set<AnyCancellable>()

    // MARK: - Initializers

    public init(
        delegate: CurrentPlayerStateViewModelDelegate,
        playMediaUseCase: PlayMediaWithInfoUseCase
    ) {

        self.delegate = delegate
        self.playMediaUseCase = playMediaUseCase
        
        observePlayerState(playMediaUseCase: playMediaUseCase)
    }
    
    private func observePlayerState(playMediaUseCase: PlayMediaWithInfoUseCase) {

        playMediaUseCase.state.publisher
            .sink { [weak self] state in self?.updateState(state) }
            .store(in: &observers)
    }
    
    private func updateState(_ state: PlayMediaWithInfoUseCaseState) {
        
        guard case .activeSession(_, let loadState) = state else {
            
            self.state.value = .notActive
            return
        }
        
        switch loadState {
            
        case .loading:
            self.state.value = .loading
            
        case .loadFailed:
            self.state.value = .notActive
            
        case .loaded(let playerState, _, let mediaInfo):
            self.state.value = .active(mediaInfo: mediaInfo, state: playerState.map())
        }
    }
}

// MARK: - Input Methods

extension CurrentPlayerStateViewModelImpl {

    public func open() {

        delegate?.currentPlayerStateViewModelDidOpen()
    }

    public func togglePlay() {

        playMediaUseCase.togglePlay()
    }
}

fileprivate extension PlayMediaWithTranslationsUseCasePlayerState {
    
    func map() -> PlayerState {
        
        switch self {
        
        case .initial:
            return .stopped
            
        case .playing, .pronouncingTranslations:
            return .playing
            
        case .paused:
            return .paused
            
        case .stopped:
            return .stopped
            
        case .finished:
            return .stopped
        }
    }
}
