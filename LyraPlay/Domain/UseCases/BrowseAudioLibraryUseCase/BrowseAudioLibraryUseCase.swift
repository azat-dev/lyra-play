//
//  BrowseAudioLibraryUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public enum BrowseAudioLibraryUseCaseError: Error {

    case fileNotFound
    case internalError
}

public protocol BrowseAudioLibraryUseCaseInput {}

public protocol BrowseAudioLibraryUseCaseOutput {

    func listFiles() async -> Result<[AudioFileInfo], BrowseAudioLibraryUseCaseError>

    func getFileInfo(fileId: UUID) async -> Result<AudioFileInfo, BrowseAudioLibraryUseCaseError>

    func fetchImage(name: String) async -> Result<Data, BrowseAudioLibraryUseCaseError>
}

public protocol BrowseAudioLibraryUseCase: BrowseAudioLibraryUseCaseOutput, BrowseAudioLibraryUseCaseInput {}
