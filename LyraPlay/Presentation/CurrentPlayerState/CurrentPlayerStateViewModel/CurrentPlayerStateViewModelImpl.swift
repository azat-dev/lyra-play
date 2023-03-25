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
    
    private let getLastPlayedMediaUseCaseFactory: GetLastPlayedMediaUseCaseFactory
    
    private let showMediaInfoUseCaseFactory: ShowMediaInfoUseCaseFactory
    
    private var showLastPlayedMediaTask: Task<Void, Never>?
    
    // MARK: - Initializers
    
    public init(
        delegate: CurrentPlayerStateViewModelDelegate,
        playMediaUseCase: PlayMediaWithInfoUseCase,
        getLastPlayedMediaUseCaseFactory: GetLastPlayedMediaUseCaseFactory,
        showMediaInfoUseCaseFactory: ShowMediaInfoUseCaseFactory
    ) {
        
        self.delegate = delegate
        self.playMediaUseCase = playMediaUseCase
        self.getLastPlayedMediaUseCaseFactory = getLastPlayedMediaUseCaseFactory
        self.showMediaInfoUseCaseFactory = showMediaInfoUseCaseFactory
        
        observeLoadingState(playMediaUseCase: playMediaUseCase)
    }
    
    deinit {
        showLastPlayedMediaTask?.cancel()
        observers.removeAll()
    }
    
    private func observeLoadingState(playMediaUseCase: PlayMediaWithInfoUseCase) {
        
        if case .noActiveSession = playMediaUseCase.state.value {
            
            showLastPlayedMediaTask?.cancel()
            
            showLastPlayedMediaTask = Task {
                await showLastPlayedMedia()
            }
        }
        
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
                
                self.showLastPlayedMediaTask?.cancel()
                
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
    
    private func showLastPlayedMedia() async {
        
        let getLastPlayedMediaUseCase = getLastPlayedMediaUseCaseFactory.make()
        
        let result = await getLastPlayedMediaUseCase.getLastPlayedMedia()
        
        guard
            !Task.isCancelled,
            case .success(let lastPlayedMediaId) = result,
            let lastPlayedMediaId = lastPlayedMediaId
        else {
            return
        }

        let showMediaInfoUseCase = showMediaInfoUseCaseFactory.make()
        
        let mediaResult = await showMediaInfoUseCase.fetchInfo(trackId: lastPlayedMediaId)
        
        guard
            !Task.isCancelled,
            case .success(let mediaInfo) = mediaResult
        else {
            return
        }

        self.state.value = .active(mediaInfo: mediaInfo, state: .init(.stopped))
    }
}

// MARK: - Input Methods

extension CurrentPlayerStateViewModelImpl {
    
    public func open() {
        
        if case .noActiveSession = playMediaUseCase.state.value {
            
            if
                case .active(let mediaInfo, _) = state.value,
                let mediaId = UUID(uuidString: mediaInfo.id)
            {
                
                Task {
                    let _ = await playMediaUseCase.prepare(
                        session: .init(
                            mediaId: mediaId,
                            learningLanguage: "English",
                            nativeLanguage: "FIXME"
                        )
                    )                    
                }
            }
        }
        
        delegate?.currentPlayerStateViewModelDidOpen()
    }
    
    public func togglePlay() {
        
        if case .noActiveSession = playMediaUseCase.state.value {
            
            if
                case .active(let mediaInfo, _) = state.value,
                let mediaId = UUID(uuidString: mediaInfo.id)
            {
                
                Task {
                    let _ = await playMediaUseCase.prepare(
                        session: .init(
                            mediaId: mediaId,
                            learningLanguage: "English",
                            nativeLanguage: "FIXME"
                        )
                    )
                    
                    let _ = playMediaUseCase.resume()
                }
                return
            }
        }
        
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
