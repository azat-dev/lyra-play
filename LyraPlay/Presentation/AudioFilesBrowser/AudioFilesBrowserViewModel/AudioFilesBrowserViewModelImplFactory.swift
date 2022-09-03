//
//  AudioFilesBrowserViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.2022.
//

import Foundation

public final class AudioFilesBrowserViewModelImplFactory: AudioFilesBrowserViewModelFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func create(
        coordinator: LibraryCoordinatorInput,
        browseUseCase: BrowseAudioLibraryUseCase,
        importFileUseCase: ImportAudioFileUseCase
    ) -> some AudioFilesBrowserViewModel {

        return AudioFilesBrowserViewModelImpl(
            coordinator: coordinator,
            browseUseCase: browseUseCase,
            importFileUseCase: importFileUseCase
        )
    }
}