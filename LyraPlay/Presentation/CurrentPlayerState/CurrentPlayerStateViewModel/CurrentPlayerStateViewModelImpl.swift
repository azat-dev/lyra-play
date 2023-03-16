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
    
    private let playerState = CurrentValueSubject<PlayerState, Never>(.stopped)
    
    private var observers = Set<AnyCancellable>()
    
    private var playingStateObserver: AnyCancellable?
    
    private var loadStateObserver: AnyCancellable?
    
    // MARK: - Initializers
    
    public init(
        delegate: CurrentPlayerStateViewModelDelegate,
        playMediaUseCase: PlayMediaWithInfoUseCase
    ) {
        
        self.delegate = delegate
        self.playMediaUseCase = playMediaUseCase
        
        observeLoadingState(playMediaUseCase: playMediaUseCase)
    }
    
    private func observeLoadingState(playMediaUseCase: PlayMediaWithInfoUseCase) {
        
        playMediaUseCase.state
            .sink { [weak self] state in self?.updateState(state) }
            .store(in: &observers)
    }
    
    private func updatePlayerState(with newState: PlayMediaWithInfoUseCasePlayerState) {
        
        playerState.value = newState.map()
    }
    
    private func pipePlayingState(from sourcePlayerState: CurrentValueSubject<PlayMediaWithInfoUseCasePlayerState, Never>) {
        
        playingStateObserver = sourcePlayerState.sink { [weak self ] newState in
            self?.updatePlayerState(with: newState)
        }
    }
    
    private func pipeLoadState(from state: CurrentValueSubject<PlayMediaWithInfoUseCaseLoadState, Never>) {
        
        loadStateObserver = state.sink { [weak self] newState in
            
            guard let self = self else {
                return
            }
            
            switch newState {
                
            case .loading:
                self.state.value = .loading
                
            case .loadFailed:
                self.state.value = .notActive
                
            case .loaded(let sourcePlayerState, let mediaInfo):
                
                self.pipePlayingState(from: sourcePlayerState)
                self.state.value = .active(mediaInfo: mediaInfo, state: self.playerState)
            }
        }
        
    }
    
    private func updateState(_ state: PlayMediaWithInfoUseCaseState) {
        
        playingStateObserver = nil
        loadStateObserver = nil
        
        guard case .activeSession(_, let loadState) = state else {
            
            self.state.value = .notActive
            return
        }
        
        pipeLoadState(from: loadState)
    }
}

// MARK: - Input Methods

extension CurrentPlayerStateViewModelImpl {
    
    public func open() {
        
        delegate?.currentPlayerStateViewModelDidOpen()
    }
    
    public func togglePlay() {
        
        let _ = playMediaUseCase.togglePlay()
    }
}

fileprivate extension PlayMediaWithInfoUseCasePlayerState {
    
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
