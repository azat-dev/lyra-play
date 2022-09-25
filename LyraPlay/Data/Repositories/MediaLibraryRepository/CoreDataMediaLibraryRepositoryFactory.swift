//
//  CoreDataMediaLibraryRepositoryFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class CoreDataMediaLibraryRepositoryFactory: MediaLibraryRepositoryFactory {

    // MARK: - Properties

    private let coreDataStore: CoreDataStore

    // MARK: - Initializers

    public init(coreDataStore: CoreDataStore) {

        self.coreDataStore = coreDataStore
    }

    // MARK: - Methods

    public func create() -> MediaLibraryRepository {

        return CoreDataMediaLibraryRepository(coreDataStore: coreDataStore)
    }
}
