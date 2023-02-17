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
    private let playMediaUseCaseFactory: PlayMediaWithInfoUseCaseFactory

    // MARK: - Initializers

    public init(
        showMediaInfoUseCase: ShowMediaInfoUseCase,
        playMediaUseCaseFactory: PlayMediaWithInfoUseCaseFactory
    ) {

        self.showMediaInfoUseCase = showMediaInfoUseCase
        self.playMediaUseCaseFactory = playMediaUseCaseFactory
    }

    // MARK: - Methods

    public func make(
        mediaId: UUID,
        delegate: LibraryItemViewModelDelegate
    ) -> LibraryItemViewModel {
        
        let playMediaUseCase = playMediaUseCaseFactory.make()

        return LibraryItemViewModelImpl(
            trackId: mediaId,
            delegate: delegate,
            showMediaInfoUseCase: showMediaInfoUseCase,
            playMediaUseCase: playMediaUseCase
        )
    }
}
