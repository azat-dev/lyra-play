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

    public func create(delegate: MediaLibraryBrowserViewModelDelegate) -> MediaLibraryBrowserViewModel {

        let browseUseCase = browseMediaLibraryUseCaseFactory.create()
        let importFileUseCase = importAudioFileUseCaseFactory.create()

        return MediaLibraryBrowserViewModelImpl(
            delegate: delegate,
            browseUseCase: browseUseCase,
            importFileUseCase: importFileUseCase
        )
    }
}
