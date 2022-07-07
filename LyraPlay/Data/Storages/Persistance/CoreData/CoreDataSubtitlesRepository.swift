//
//  CoreDataSubtitlesRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.07.22.
//

import Foundation
import CoreData

// MARK: - Implementations

public final class CoreDataSubtitlesRepository: SubtitlesRepository {
    
    private let coreDataStore: CoreDataStore
    
    public init(coreDataStore: CoreDataStore) {
        self.coreDataStore = coreDataStore
    }
    
    private func getManagedItem(mediaFileId: UUID, language: String) async throws -> ManagedSubtitles?  {

        let managedItems = try coreDataStore.performSync { context -> [ManagedSubtitles] in
            
            let request = ManagedSubtitles.fetchRequest()
            request.fetchLimit = 1
            request.resultType = .managedObjectResultType
            request.predicate = NSPredicate(
                format: "%K = %@ AND %K = %@ ",
                #keyPath(ManagedSubtitles.mediaFileId),
                mediaFileId.uuidString,
                #keyPath(ManagedSubtitles.language),
                language
            )
            
            return try context.fetch(request)
        }
        
        return managedItems.first
    }
    
    public func put(info item: SubtitlesInfo) async -> Result<SubtitlesInfo, SubtitlesRepositoryError> {
        
        var existingItem: ManagedSubtitles? = nil
        
        do {
            
            existingItem = try await getManagedItem(
                mediaFileId: item.mediaFileId,
                language: item.language
            )
        } catch {
            return .failure(.internalError(error))
        }
        
        let updatedItem = try! coreDataStore.performSync { context -> ManagedSubtitles in
            
            if let existingItem = existingItem {
                
                existingItem.fillFields(from: item)
                try! context.save()
                
                return existingItem
            }
            
            
            let newItem = ManagedSubtitles.create(context, from: item)
            try context.save()
            return newItem
        }
        
        return .success(updatedItem.toDomain())
    }
    
    public func fetch(mediaFileId: UUID, language: String) async -> Result<SubtitlesInfo, SubtitlesRepositoryError> {
        
        do {
            
            let item = try await getManagedItem(mediaFileId: mediaFileId, language: language)
            guard let item = item else {
                return .failure(.itemNotFound)
            }
            
            return .success(item.toDomain())
            
        } catch {
            return .failure(.internalError(error))
        }
    }
    
    public func list() async -> Result<[SubtitlesInfo], SubtitlesRepositoryError> {
        return await listFiltered(mediaFileId: nil)
    }
    
    public func list(mediaFileId: UUID) async -> Result<[SubtitlesInfo], SubtitlesRepositoryError> {
        return await listFiltered(mediaFileId: mediaFileId)
    }
    
    private func listFiltered(mediaFileId: UUID?) async -> Result<[SubtitlesInfo], SubtitlesRepositoryError> {
        
        let request = ManagedSubtitles.fetchRequest()
        
        if let mediaFileId = mediaFileId {
            
            request.predicate = NSPredicate(
                format: "%K = %@",
                #keyPath(ManagedSubtitles.mediaFileId),
                mediaFileId.uuidString
            )
        }
        
        do {
            
            let managedItems = try coreDataStore.performSync { context -> [ManagedSubtitles] in
                
                return try context.fetch(request)
            }
            
            let domainItems = managedItems.map { $0.toDomain() }
            return .success(domainItems)
            
        } catch {
            
            return .failure(.internalError(error))
        }
    }
    
    public func delete(mediaFileId: UUID, language: String) async -> Result<Void, SubtitlesRepositoryError> {
        
        do {
            
            let item = try await getManagedItem(
                mediaFileId: mediaFileId,
                language: language
            )
            
            guard let item = item else {
                return .failure(.itemNotFound)
            }
            
            try coreDataStore.performSync { context in
                
                context.delete(item)
                try context.save()
            }
            
        } catch {
            return .failure(.internalError(error))
        }
        
        return .success(())
    }
}
