//
//  LibraryItemViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

import Foundation

public final class LibraryItemViewModelImplFactory: LibraryItemViewModelFactory {

    // MARK: - Properties

    private let showMediaInfoUseCase: ShowMediaInfoUseCase
    private let currentPlayerStateUseCase: CurrentPlayerStateUseCaseOutput
    private let playMediaUseCase: PlayMediaWithTranslationsUseCase
    private let importSubtitlesUseCase: ImportSubtitlesUseCase
    private let loadSubtitlesUseCase: LoadSubtitlesUseCase

    // MARK: - Initializers

    public init(
        showMediaInfoUseCase: ShowMediaInfoUseCase,
        currentPlayerStateUseCase: CurrentPlayerStateUseCaseOutput,
        playMediaUseCase: PlayMediaWithTranslationsUseCase,
        importSubtitlesUseCase: ImportSubtitlesUseCase,
        loadSubtitlesUseCase: LoadSubtitlesUseCase
    ) {

        self.showMediaInfoUseCase = showMediaInfoUseCase
        self.currentPlayerStateUseCase = currentPlayerStateUseCase
        self.playMediaUseCase = playMediaUseCase
        self.importSubtitlesUseCase = importSubtitlesUseCase
        self.loadSubtitlesUseCase = loadSubtitlesUseCase
    }

    // MARK: - Methods

    public func create(
        mediaId: UUID,
        coordinator: LibraryItemCoordinatorInput
    ) -> LibraryItemViewModel {

        return LibraryItemViewModelImpl(
            trackId: mediaId,
            coordinator: coordinator,
            showMediaInfoUseCase: showMediaInfoUseCase,
            currentPlayerStateUseCase: currentPlayerStateUseCase,
            playMediaUseCase: playMediaUseCase,
            importSubtitlesUseCase: importSubtitlesUseCase,
            loadSubtitlesUseCase: loadSubtitlesUseCase
        )
    }
}
