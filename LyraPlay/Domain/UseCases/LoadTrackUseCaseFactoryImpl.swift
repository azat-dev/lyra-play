//
//  LoadTrackUseCaseFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public final class LoadTrackUseCaseFactoryImpl: LoadTrackUseCaseFactory {
    
    public init() {}
    
    public func create(
        audioLibraryRepository: AudioLibraryRepository,
        audioFilesRepository: FilesRepository
    ) -> LoadTrackUseCase {
        
        return LoadTrackUseCaseImpl(
            audioLibraryRepository: audioLibraryRepository,
            audioFilesRepository: audioFilesRepository
        )
    }
}
