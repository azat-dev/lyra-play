//
//  LibraryItemViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 02.07.22.
//

import Foundation

// MARK: - Interfaces

public struct LibraryItemInfoPresentation {
    
    public var title: String
    public var artist: String
    public var coverImage: Data
    public var duration: String
}

public protocol LibraryItemCoordinator {
    
    func chooseSubtitles() async -> Result<URL?, Error>
}

public protocol LibraryItemViewModelOutput {

    var isPlaying: Observable<Bool> { get }
    var info: Observable<LibraryItemInfoPresentation?> { get }
}

public protocol LibraryItemViewModelInput {
    
    func load() async
    
    func togglePlay() async
}

public protocol LibraryItemViewModel: LibraryItemViewModelOutput, LibraryItemViewModelInput {
}

// MARK: - Implementations

public final class DefaultLibraryItemViewModel: LibraryItemViewModel {
    
    private let trackId: UUID
    private let coordinator: LibraryItemCoordinator
    private let showMediaInfoUseCase: ShowMediaInfoUseCase
    private let playerControlUseCase: PlayerControlUseCase
    private let currentPlayerStateUseCase: CurrentPlayerStateUseCaseOutput
    
    public var isPlaying: Observable<Bool> = Observable(false)
    public var info: Observable<LibraryItemInfoPresentation?> = Observable(nil)
    
    public init(
        trackId: UUID,
        coordinator: LibraryItemCoordinator,
        showMediaInfoUseCase: ShowMediaInfoUseCase,
        currentPlayerStateUseCase: CurrentPlayerStateUseCaseOutput,
        playerControlUseCase: PlayerControlUseCase
    ) {
        
        self.trackId = trackId
        self.coordinator = coordinator
        self.showMediaInfoUseCase = showMediaInfoUseCase
        self.playerControlUseCase = playerControlUseCase
        self.currentPlayerStateUseCase = currentPlayerStateUseCase
        
        bind(to: currentPlayerStateUseCase)
    }
    
    private func updatePlayingState() {
        
        let currentTrackId = currentPlayerStateUseCase.info.value?.id
        let state = currentPlayerStateUseCase.state.value
        
        let isPlaying = (state == .playing && currentTrackId == trackId.uuidString)
        
        guard isPlaying != self.isPlaying.value else {
            return
        }

        self.isPlaying.value = isPlaying
    }
    
    private func bind(to currentPlayerStateUseCase: CurrentPlayerStateUseCaseOutput) {
        
        currentPlayerStateUseCase.state.observe(on: self) { [weak self] _ in
            self?.updatePlayingState()
        }
        
        currentPlayerStateUseCase.info.observe(on: self) { [weak self] _ in
            self?.updatePlayingState()
        }
    }
}

// MARK: - Input

extension DefaultLibraryItemViewModel {
    
    private func formatDuration(_ value: Double) -> String {
        return "\(value)"
    }
    
    private func mapInfo(_ info: MediaInfo) -> LibraryItemInfoPresentation {
        
        return LibraryItemInfoPresentation(
            title: info.title,
            artist: info.artist ?? "",
            coverImage: info.coverImage,
            duration: formatDuration(info.duration)
        )
    }
    
    public func load() async {
        
        let resultMediaInfo = await showMediaInfoUseCase.fetchInfo(trackId: trackId)
        
        guard case .success(let mediaInfo) = resultMediaInfo else {
            return
        }
        
        self.info.value = mapInfo(mediaInfo)
    }
    
    public func togglePlay() async {
     
        if self.isPlaying.value {
            
            let _ = await playerControlUseCase.pause()
            return
        }
        
        let _ = await playerControlUseCase.play(trackId: trackId)
    }
}
