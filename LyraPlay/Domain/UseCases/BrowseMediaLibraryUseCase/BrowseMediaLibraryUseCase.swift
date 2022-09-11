//
//  BrowseMediaLibraryUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public enum BrowseMediaLibraryUseCaseError: Error {

    case fileNotFound
    case internalError
}

public protocol BrowseMediaLibraryUseCaseInput {}

public protocol BrowseMediaLibraryUseCaseOutput {

    func listFiles() async -> Result<[AudioFileInfo], BrowseMediaLibraryUseCaseError>

    func getFileInfo(fileId: UUID) async -> Result<AudioFileInfo, BrowseMediaLibraryUseCaseError>

    func fetchImage(name: String) async -> Result<Data, BrowseMediaLibraryUseCaseError>
}

public protocol BrowseMediaLibraryUseCase: BrowseMediaLibraryUseCaseOutput, BrowseMediaLibraryUseCaseInput {}
