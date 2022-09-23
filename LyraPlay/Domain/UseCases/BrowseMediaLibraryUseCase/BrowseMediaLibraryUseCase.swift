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

    func getFileInfo(fileId: UUID) async -> Result<MediaLibraryAudioFile, BrowseMediaLibraryUseCaseError>

    func fetchImage(name: String) async -> Result<Data, BrowseMediaLibraryUseCaseError>
    
    func listItems(folderId: UUID?) async -> Result<[MediaLibraryItem], BrowseMediaLibraryUseCaseError>
    
    func getItem(id: UUID) async -> Result<MediaLibraryItem, BrowseMediaLibraryUseCaseError>
}

public protocol BrowseMediaLibraryUseCase: BrowseMediaLibraryUseCaseOutput, BrowseMediaLibraryUseCaseInput {}
