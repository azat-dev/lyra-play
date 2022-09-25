//
//  BrowseMediaLibraryUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

public protocol BrowseMediaLibraryUseCaseFactory {

    func create() -> BrowseMediaLibraryUseCase
}
