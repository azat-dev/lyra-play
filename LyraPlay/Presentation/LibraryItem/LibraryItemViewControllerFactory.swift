//
//  LibraryItemViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.07.22.
//

import Foundation

public final class LibraryItemViewControllerFactory {
    
    private var coordinator: LibraryItemCoordinator
    private var showMediaInfoUseCase: ShowMediaInfoUseCase
    private var currentPlayerStateUseCase: CurrentPlayerStateUseCaseOutput
    private var playerControlUseCase: PlayerControlUseCase
    
    init(
        coordnator: LibraryItemCoordinator,
        showMediaInfoUseCase: ShowMediaInfoUseCase,
        currentPlayerStateUseCase: CurrentPlayerStateUseCaseOutput,
        playerControlUseCase: PlayerControlUseCase
    ) {
        
        self.coordinator = coordnator
        self.showMediaInfoUseCase = showMediaInfoUseCase
        self.currentPlayerStateUseCase = currentPlayerStateUseCase
        self.playerControlUseCase = playerControlUseCase
    }
    
    public func build(with trackId: UUID) -> LibraryItemViewController {
        
        let viewModel = DefaultLibraryItemViewModel(
            trackId: trackId,
            coordinator: coordinator,
            showMediaInfoUseCase: showMediaInfoUseCase,
            currentPlayerStateUseCase: currentPlayerStateUseCase,
            playerControlUseCase: playerControlUseCase
        )
        
        return LibraryItemViewController(viewModel: viewModel)
    }
}
