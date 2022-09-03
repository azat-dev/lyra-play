//
//  AudioFilesBrowserViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

public protocol AudioFilesBrowserViewModelFactory {

    associatedtype ViewModel: AudioFilesBrowserViewModel
    
    func create(
        coordinator: LibraryCoordinatorInput,
        browseUseCase: BrowseAudioLibraryUseCase,
        importFileUseCase: ImportAudioFileUseCase
    ) -> ViewModel
}
