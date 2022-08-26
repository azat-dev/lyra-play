//
//  BrowseAudioLibraryUseCaseFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public final class BrowseAudioLibraryUseCaseFactoryImpl: BrowseAudioLibraryUseCaseFactory {
    
    public func create(
        audioLibraryRepository: AudioLibraryRepository,
        imagesRepository: FilesRepository
    ) -> BrowseAudioLibraryUseCase {
        
        return BrowseAudioLibraryUseCaseImpl(
            audioLibraryRepository: audioLibraryRepository,
            imagesRepository: imagesRepository
        )
    }
}
