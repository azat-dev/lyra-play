//
//  AudioFilesBrowserViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

import Foundation

public final class AudioFilesBrowserViewModelImplFactory: AudioFilesBrowserViewModelFactory {

    // MARK: - Properties

    private let browseAudioLibraryUseCaseFactory: BrowseAudioLibraryUseCaseFactory
    private let importAudioFileUseCaseFactory: ImportAudioFileUseCaseFactory

    // MARK: - Initializers

    public init(
        browseAudioLibraryUseCaseFactory: BrowseAudioLibraryUseCaseFactory,
        importAudioFileUseCaseFactory: ImportAudioFileUseCaseFactory
    ) {

        self.browseAudioLibraryUseCaseFactory = browseAudioLibraryUseCaseFactory
        self.importAudioFileUseCaseFactory = importAudioFileUseCaseFactory
    }

    // MARK: - Methods

    public func create(delegate: AudioFilesBrowserViewModelDelegate) -> AudioFilesBrowserViewModel {

        let browseUseCase = browseAudioLibraryUseCaseFactory.create()
        let importFileUseCase = importAudioFileUseCaseFactory.create()

        return AudioFilesBrowserViewModelImpl(
            delegate: delegate,
            browseUseCase: browseUseCase,
            importFileUseCase: importFileUseCase
        )
    }
}
