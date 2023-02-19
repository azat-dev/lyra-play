//
//  MediaLibraryBrowserViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

import Foundation

public final class MediaLibraryBrowserViewModelImplFactory: MediaLibraryBrowserViewModelFactory {

    // MARK: - Properties

    private let browseMediaLibraryUseCaseFactory: BrowseMediaLibraryUseCaseFactory
    private let importAudioFileUseCaseFactory: ImportAudioFileUseCaseFactory

    // MARK: - Initializers

    public init(
        browseMediaLibraryUseCaseFactory: BrowseMediaLibraryUseCaseFactory,
        importAudioFileUseCaseFactory: ImportAudioFileUseCaseFactory
    ) {

        self.browseMediaLibraryUseCaseFactory = browseMediaLibraryUseCaseFactory
        self.importAudioFileUseCaseFactory = importAudioFileUseCaseFactory
    }

    // MARK: - Methods

    public func make(folderId: UUID?, delegate: MediaLibraryBrowserViewModelDelegate) -> MediaLibraryBrowserViewModel {

        let browseUseCase = browseMediaLibraryUseCaseFactory.make()
        let importFileUseCase = importAudioFileUseCaseFactory.make()

        return MediaLibraryBrowserViewModelImpl(
            folderId: folderId,
            delegate: delegate,
            browseUseCase: browseUseCase,
            importFileUseCase: importFileUseCase
        )
    }
}
