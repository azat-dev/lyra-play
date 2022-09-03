//
//  AudioFilesBrowserViewModelFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public final class AudioFilesBrowserViewModelFactoryImpl: AudioFilesBrowserViewModelFactory {
    
    public typealias ViewModel = AudioFilesBrowserViewModelImpl
    
    public init() {}
    
    public func create(
        coordinator: LibraryCoordinatorInput,
        browseUseCase: BrowseAudioLibraryUseCase,
        importFileUseCase: ImportAudioFileUseCase
    ) -> ViewModel {
    
        return AudioFilesBrowserViewModelImpl(
            coordinator: coordinator,
            browseUseCase: browseUseCase,
            importFileUseCase: importFileUseCase
        )
    }
}
