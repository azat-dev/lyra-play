//
//  CoreDataAudioLibraryRepositoryFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class CoreDataAudioLibraryRepositoryFactory: AudioLibraryRepositoryFactory {

    // MARK: - Properties

    private let coreDataStore: CoreDataStore

    // MARK: - Initializers

    public init(coreDataStore: CoreDataStore) {

        self.coreDataStore = coreDataStore
    }

    // MARK: - Methods

    public func create() -> AudioLibraryRepository {

        return CoreDataAudioLibraryRepository(coreDataStore: coreDataStore)
    }
}
