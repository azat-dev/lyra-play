//
//  ImportAudioFileUseCaseFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public final class ImportAudioFileUseCaseFactoryImpl: ImportAudioFileUseCaseFactory {
    
    public func create(
        audioLibraryRepository: AudioLibraryRepository,
        audioFilesRepository: FilesRepository,
        imagesRepository: FilesRepository,
        tagsParser: TagsParser
    ) -> ImportAudioFileUseCase {
        
        return ImportAudioFileUseCaseImpl(
            audioLibraryRepository: audioLibraryRepository,
            audioFilesRepository: audioFilesRepository,
            imagesRepository: imagesRepository,
            tagsParser: tagsParser
        )
    }
}
