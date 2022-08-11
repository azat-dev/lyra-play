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
    private var playMediaUseCase: PlayMediaUseCase
    private var importSubtitlesUseCase: ImportSubtitlesUseCase
    private var loadSubtitlesUseCase: LoadSubtitlesUseCase
    
    init(
        coordnator: LibraryItemCoordinator,
        showMediaInfoUseCase: ShowMediaInfoUseCase,
        currentPlayerStateUseCase: CurrentPlayerStateUseCaseOutput,
        playMediaUseCase: PlayMediaUseCase,
        importSubtitlesUseCase: ImportSubtitlesUseCase,
        loadSubtitlesUseCase: LoadSubtitlesUseCase
    ) {
        
        self.coordinator = coordnator
        self.showMediaInfoUseCase = showMediaInfoUseCase
        self.currentPlayerStateUseCase = currentPlayerStateUseCase
        self.playMediaUseCase = playMediaUseCase
        self.importSubtitlesUseCase = importSubtitlesUseCase
        self.loadSubtitlesUseCase = loadSubtitlesUseCase
    }
    
    public func build(with trackId: UUID) -> LibraryItemViewController {
        
        let viewModel = DefaultLibraryItemViewModel(
            trackId: trackId,
            coordinator: coordinator,
            showMediaInfoUseCase: showMediaInfoUseCase,
            currentPlayerStateUseCase: currentPlayerStateUseCase,
            playMediaUseCase: playMediaUseCase,
            importSubtitlesUseCase: importSubtitlesUseCase,
            loadSubtitlesUseCase: loadSubtitlesUseCase
        )
        
        return LibraryItemViewController(viewModel: viewModel)
    }
}
