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
        
        let action: CoreDataStore.ActionCallBack = { context -> ManagedDictionaryItem in
            
            if let existingItem = existingItem {
                
                let createdAt = existingItem.createdAt
                
                existingItem.fillFields(from: item)
                existingItem.updatedAt = .now
                existingItem.createdAt = createdAt
                
                try context.save()

                return existingItem
            }
            
            let newItem = ManagedDictionaryItem.create(context, from: item)
            newItem.createdAt = .now
            try context.save()
            
            return newItem
        }
        
        do {
            
            let updatedItem = try coreDataStore.performSync(action)
            return .success(updatedItem.toDomain())

        } catch {

            
            guard
                let conflictList = (error as NSError).userInfo["conflictList"] as? [NSConstraintConflict]
            else {
                return .failure(.internalError(error))
            }
            
            let isConflict = conflictList.contains { item in
                item.constraint.contains(#keyPath(ManagedDictionaryItem.originalText)) &&
                item.constraint.contains(#keyPath(ManagedDictionaryItem.language))
            }
            
            if isConflict {
                return .failure(.itemMustBeUnique)
            }
            
            return .failure(.internalError(error))
        }
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
    
    private static func predicate(for itemsFilter: DictionaryItemFilter) -> NSPredicate {

        var key: String
        var value: Any
        
        switch itemsFilter {
            
        case .lemma(let lemma):
            key = #keyPath(ManagedDictionaryItem.lemma)
            value = lemma
            
        case .originalText(let originalText):
            key = #keyPath(ManagedDictionaryItem.originalText)
            value = originalText
        }
        
        return NSComparisonPredicate(
            leftExpression: .init(forKeyPath: key),
            rightExpression: .init(forConstantValue: value),
            modifier: .any,
            type: .equalTo,
            options: .caseInsensitive
        )
    }
    
    private func searchItems(with predicates: [NSPredicate]) async throws -> [ManagedDictionaryItem] {
        
        var predicate: NSPredicate
        
        if predicates.count == 1 {
            
            predicate = predicates.first!

        } else {
            predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        }
        
        let action: CoreDataStore.ActionCallBack<[ManagedDictionaryItem]> = { context in
            
            let request = ManagedDictionaryItem.fetchRequest()
            
            request.predicate = predicate
            request.resultType = .managedObjectResultType
            
            return try context.fetch(request)
        }

        return try coreDataStore.performSync(action)
    }
    
    public func searchItems(with itemsFilters: [DictionaryItemFilter]) async -> Result<[DictionaryItem], DictionaryRepositoryError> {

        let predicatesLimit = 800
        var predicates = [NSPredicate]()
        
        var itemsById = [UUID: ManagedDictionaryItem]()
        
        for filter in itemsFilters {
            
            let predicate = Self.predicate(for: filter)
            predicates.append(predicate)
            
            if predicates.count >= predicatesLimit {
                
                do {
                    
                    let foundItems = try await searchItems(with: predicates)
                    foundItems.forEach { itemsById[$0.id!] = $0 }
                    predicates.removeAll()
                
                } catch {
                    return .failure(.internalError(error))
                }
            }
        }
        
        let items = [DictionaryItem](itemsById.values.map { $0.toDomain() })
        return .success(items)
    }
    
    public func listItems() async -> Result<[DictionaryItem], DictionaryRepositoryError> {
        
        let action: CoreDataStore.ActionCallBack<[ManagedDictionaryItem]> = { context in
            
            let request = ManagedDictionaryItem.fetchRequest()
            
            request.resultType = .managedObjectResultType
            request.sortDescriptors = [
                .init(key: #keyPath(ManagedDictionaryItem.originalText), ascending: true)
            ]
            
            return try context.fetch(request)
        }

        var managedItems: [ManagedDictionaryItem]
        
        do {
            
            managedItems = try coreDataStore.performSync(action)
            
        } catch {
            return .failure(.internalError(error))
        }
        
        let items = managedItems.map { $0.toDomain() }
        return .success(items)
    }
}
