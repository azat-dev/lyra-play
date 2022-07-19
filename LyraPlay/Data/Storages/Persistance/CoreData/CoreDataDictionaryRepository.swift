//
//  CoreDataDictionaryRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.07.22.
//

import Foundation
import CoreData

// MARK: - Implementations

public final class CoreDataDictionaryRepository: DictionaryRepository {
    
    private let coreDataStore: CoreDataStore
    
    public init(coreDataStore: CoreDataStore) {
        self.coreDataStore = coreDataStore
    }
    
    private func getManagedItem(originalText: String, language: String) async throws -> ManagedDictionaryItem?  {
        
        let managedItems = try coreDataStore.performSync { context -> [ManagedDictionaryItem] in
            
            let request = ManagedDictionaryItem.fetchRequest()
            request.fetchLimit = 1
            request.resultType = .managedObjectResultType
            request.predicate = NSPredicate(
                format: "%K = %@ AND %K = %@ ",
                #keyPath(ManagedDictionaryItem.originalText),
                originalText,
                #keyPath(ManagedDictionaryItem.language),
                language
            )
            
            return try context.fetch(request)
        }
        
        return managedItems.first
    }
    
    private func getManagedItem(id: UUID) async throws -> ManagedDictionaryItem?  {
        
        let managedItems = try coreDataStore.performSync { context -> [ManagedDictionaryItem] in
            
            let request = ManagedDictionaryItem.fetchRequest()
            request.fetchLimit = 1
            request.resultType = .managedObjectResultType
            request.predicate = NSPredicate(
                format: "%K = %@",
                (\ManagedAudioFile.id)._kvcKeyPathString!,
                id.uuidString
            )
            
            return try context.fetch(request)
        }
        
        return managedItems.first
    }
    
    public func putItem(_ item: DictionaryItem) async -> Result<DictionaryItem, DictionaryRepositoryError> {
        
        var existingItem: ManagedDictionaryItem? = nil
        
        
        if let itemId = item.id {
            
            do {
                
                existingItem = try await getManagedItem(id: itemId)
                
                if existingItem == nil {
                    return .failure(.itemNotFound)
                }
                
            } catch {
                return .failure(.internalError(error))
            }
        }
        
        let updatedItem = try! coreDataStore.performSync { context -> ManagedDictionaryItem in
            
            if let existingItem = existingItem {
                
                let createdAt = existingItem.createdAt
                
                existingItem.fillFields(from: item)
                existingItem.updatedAt = .now
                existingItem.createdAt = createdAt
                try! context.save()
                
                return existingItem
            }
            
            let newItem = ManagedDictionaryItem.create(context, from: item)
            newItem.createdAt = .now
            try context.save()
            return newItem
        }
        
        return .success(updatedItem.toDomain())
    }
    
    public func getItem(id: UUID) async -> Result<DictionaryItem, DictionaryRepositoryError> {
        
        do {
            
            let item = try await getManagedItem(id: id)
            guard let item = item else {
                return .failure(.itemNotFound)
            }
            
            return .success(item.toDomain())
            
        } catch {
            return .failure(.internalError(error))
        }
    }
    
    public func deleteItem(id: UUID) async -> Result<Void, DictionaryRepositoryError> {
        
        do {
            
            let item = try await getManagedItem(id: id)
            
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
