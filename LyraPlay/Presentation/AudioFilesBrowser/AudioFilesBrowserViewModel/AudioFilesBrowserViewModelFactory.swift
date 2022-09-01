//
//  AudioFilesBrowserViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

public protocol AudioFilesBrowserViewModelFactory {

    func create(
        coordinator: LibraryCoordinatorInput,
        browseUseCase: BrowseAudioLibraryUseCase,
        importFileUseCase: ImportAudioFileUseCase
    ) -> AudioFilesBrowserViewModel
}