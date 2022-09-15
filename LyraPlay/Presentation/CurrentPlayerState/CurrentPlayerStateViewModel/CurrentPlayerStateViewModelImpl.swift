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
    
    private let playMediaUseCase: PlayMediaWithTranslationsUseCase
    private let showMediaInfoUseCase: ShowMediaInfoUseCase
    public var state = CurrentValueSubject<CurrentPlayerStateViewModelState, Never>(.loading)
    
    private var observers = Set<AnyCancellable>()

    // MARK: - Initializers

    public init(
        delegate: CurrentPlayerStateViewModelDelegate,
        playMediaUseCase: PlayMediaWithTranslationsUseCase,
        showMediaInfoUseCase: ShowMediaInfoUseCase
    ) {

        self.delegate = delegate
        self.playMediaUseCase = playMediaUseCase
        self.showMediaInfoUseCase = showMediaInfoUseCase
        
        observePlayerState(playMediaUseCase: playMediaUseCase)
    }
    
    private func loadInfo(mediaId: UUID) async {
        
        let result = await showMediaInfoUseCase.fetchInfo(trackId: mediaId)
        
        guard case .success(let mediaInfo) = result else {
            return
        }
        
        guard case .loading = state.value else {
            return
        }
        
        let playerState = playMediaUseCase.state.value.map()
        
        state.value = .active(
            mediaInfo: mediaInfo,
            state: playerState
        )
    }
    
    private func observePlayerState(playMediaUseCase: PlayMediaWithTranslationsUseCase) {

        var prevMediaId: UUID?
        
        playMediaUseCase.state.publisher.sink { [weak self] state in
  
            defer { prevMediaId = state.session?.mediaId }
            
            guard let self = self else {
                return
            }

            guard let session = state.session else {
                
                self.state.value = .notActive
                return
            }
            
            if prevMediaId != session.mediaId {

                self.state.value = .loading
                
                Task {
                    await self.loadInfo(mediaId: session.mediaId)
                }
                
                return
            }
            
        }.store(in: &observers)
    }
}

// MARK: - Input Methods

extension CurrentPlayerStateViewModelImpl {

    public func open() {

        delegate?.currentPlayerStateViewModelDidOpen()
    }

    public func togglePlay() {

        fatalError()
    }
}

fileprivate extension PlayMediaWithTranslationsUseCaseState {
    
    func map() -> PlayerState {
        
        switch self {
            
        case .initial, .loading, .loadFailed, .loaded, .stopped:
            return .stopped
            
        case .playing, .pronouncingTranslations:
            return .playing
            
        case .paused, .finished:
            return .paused
        }
    }
}
