//
//  BrowseAudioLibraryUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public protocol BrowseAudioLibraryUseCaseFactory {
    
    func create(audioLibraryRepository: AudioLibraryRepository, imagesRepository: FilesRepository) -> BrowseAudioLibraryUseCase
}
