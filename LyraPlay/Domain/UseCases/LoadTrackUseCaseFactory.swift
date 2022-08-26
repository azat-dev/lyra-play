//
//  LoadTrackUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public protocol LoadTrackUseCaseFactory {
    
    func create(
        audioLibraryRepository: AudioLibraryRepository,
        audioFilesRepository: FilesRepository
    ) -> LoadTrackUseCase
}
