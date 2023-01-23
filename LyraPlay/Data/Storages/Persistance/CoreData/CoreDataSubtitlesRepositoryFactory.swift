//
//  CoreDataSubtitlesRepositoryFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 23.01.23.
//

import Foundation

public class CoreDataSubtitlesRepositoryFactory: SubtitlesRepositoryFactory {
    
    // MARK: - Properties
    
    private let semaphore = DispatchSemaphore(value: 1)
    
    private let coreDataStore: CoreDataStore
    
    private weak var instance: SubtitlesRepository?
    
    // MARK: - Initializers
    
    public init(coreDataStore: CoreDataStore) {
        
        self.coreDataStore = coreDataStore
    }
    
    // MARK: - Methods
    
    public func create() -> SubtitlesRepository {
        defer { semaphore.signal() }
        
        semaphore.wait()
        
        if let instance = instance {
            return instance
        }
        
        let newInstance = CoreDataSubtitlesRepository(coreDataStore: coreDataStore)
        instance = newInstance
        
        return newInstance
    }
}
