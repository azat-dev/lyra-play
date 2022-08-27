//
//  LibraryItemModuleFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.08.22.
//

import Foundation

public protocol LibraryItemModuleFactory {
    
    func create(
        mediaId: UUID,
        coordinator: LibraryItemCoordinatorInput,
        viewModel: LibraryItemViewModel,
        showMediaInfoUseCase: ShowMediaInfoUseCase,
        currentPlayerStateUseCaseOutput: CurrentPlayerStateUseCaseOutput,
        playMediaWithTranslationsUseCase: PlayMediaWithTranslationsUseCase,
        importSubtitlesUseCase: ImportSubtitlesUseCase,
        loadSubtitlesUseCase: LoadSubtitlesUseCase
    ) -> PresentableModuleImpl<LibraryItemViewModel>
}

