//
//  CoreDataMediaLibraryRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation
import CoreData

public final class CoreDataMediaLibraryRepository: MediaLibraryRepository {
    
    // MARK: - Properties
    
    private let coreDataStore: CoreDataStore
    
    // MARK: - Initializers
    
    public init(coreDataStore: CoreDataStore) {
        
        self.coreDataStore = coreDataStore
    }
}

// MARK: - Input Methods

extension CoreDataMediaLibraryRepository {
    
    private func createItem<DomainType>(
        parentId: UUID?,
        fillDTO: @escaping (inout ManagedLibraryItem) -> Void,
        mapToDomainType: @escaping (ManagedLibraryItem) -> DomainType
    ) async -> Result<DomainType, MediaLibraryRepositoryError> {
        
        
        let action = { (context: NSManagedObjectContext) throws -> DomainType in
            
            var parentItem: ManagedLibraryItem!

            if let parentId = parentId {
                
                guard let parent = try self.getManagedItem(id: parentId, context: context) else {
                    throw MediaLibraryRepositoryError.parentNotFound
                }
                    
                guard parent.isFolder else {
                    throw MediaLibraryRepositoryError.parentIsNotFolder
                }
                
                parentItem = parent
                
            } else {
                
                parentItem = try self.getRootFolderItemOrCreate(context: context)
            }

            var newItem = ManagedLibraryItem(context: context)

            fillDTO(&newItem)
            
 
            newItem.id = UUID()
            newItem.createdAt = .now

            parentItem?.addToChildren(newItem)

            try context.save()
            return mapToDomainType(newItem)
        }
        
        do {
            
            let newItem = try await coreDataStore.perform(action)
            return .success(newItem)
            
        } catch {

            if let error = error as? MediaLibraryRepositoryError {
                return .failure(error)
            }
            
            guard
                let conflictList = (error as NSError).userInfo["conflictList"] as? [NSConstraintConflict]
            else {
                return .failure(.internalError(error))
            }
            
            let isConflict = conflictList.contains { item in
                item.constraint.contains(#keyPath(ManagedLibraryItem.parent)) &&
                item.constraint.contains(#keyPath(ManagedLibraryItem.title))
            }

            if isConflict {
                return .failure(.nameMustBeUnique)
            }
            
            return .failure(.internalError(error))
        }
    }
    
    public func createFile(data: NewMediaLibraryFileData) async -> Result<MediaLibraryFile, MediaLibraryRepositoryError> {
        
        return await createItem(
            parentId: data.parentId,
            fillDTO: { newItem in

                newItem.isFolder = false
                newItem.title = data.title
                newItem.subtitle = data.subtitle
                newItem.file = data.file
                newItem.playedTime = 0
                newItem.duration = data.duration
                newItem.genre = data.genre
                newItem.image = data.image
                newItem.lastPlayedAt = nil
            },
            mapToDomainType: { item in
              return item.toDomainFile()
            }
        )
    }
    
    public func createFolder(data: NewMediaLibraryFolderData) async -> Result<MediaLibraryFolder, MediaLibraryRepositoryError> {

        return await createItem(
            parentId: data.parentId,
            fillDTO: { newItem in

                newItem.isFolder = true
                newItem.title = data.title
                newItem.image = data.image

            },
            mapToDomainType: { item in
              return item.toDomainFolder()
            }
        )
    }
    
    public func deleteItem(id: UUID) async -> Result<Void, MediaLibraryRepositoryError> {
        
        
        let action = { (context: NSManagedObjectContext) throws -> Result<Void, MediaLibraryRepositoryError> in
            
            guard let managedFile = try? self.getManagedItem(id: id, context: context) else {
                return .failure(.fileNotFound)
            }
            
            context.delete(managedFile)
            try context.save()
            
            return .success(())
        }
        
        do {
            
            return try await coreDataStore.perform(action)
            
        } catch {
            
            return .failure(.internalError(error))
        }
    }
    
    public func updateFile(data: MediaLibraryFile) async -> Result<MediaLibraryFile, MediaLibraryRepositoryError> {
        
        var updatedData = data
        updatedData.updatedAt = .now
        
        let action = { (context: NSManagedObjectContext) throws -> Result<MediaLibraryFile, MediaLibraryRepositoryError> in
            
            guard let managedFile = try self.getManagedItem(id: updatedData.id, context: context) else {
                return .failure(.fileNotFound)
            }
            
            guard !managedFile.isFolder else {
                return .failure(.internalError(nil))
            }
            
            managedFile.updatedAt = updatedData.updatedAt
            managedFile.title = updatedData.title
            managedFile.subtitle = updatedData.subtitle
            managedFile.file = updatedData.file
            managedFile.playedTime = updatedData.playedTime
            managedFile.lastPlayedAt = updatedData.lastPlayedAt
            managedFile.duration = updatedData.duration
            managedFile.genre = updatedData.genre
            managedFile.image = updatedData.image
            
            try context.save()
            return .success(managedFile.toDomainFile())
        }
        
        do {
            
            return try await coreDataStore.perform(action)
        } catch {

            return .failure(.internalError(error))
        }
    }
    
    public func updateFolder(data: MediaLibraryFolder) async -> Result<MediaLibraryFolder, MediaLibraryRepositoryError> {
        
        var updatedData = data
        updatedData.updatedAt = .now
        
        let action = { (context: NSManagedObjectContext) throws -> Result<MediaLibraryFolder, MediaLibraryRepositoryError> in
            
            guard let managedFolder = try self.getManagedItem(id: updatedData.id, context: context) else {
                
                return .failure(.fileNotFound)
            }
            
            guard managedFolder.isFolder else {
                
                return .failure(.internalError(nil))
            }
            
            managedFolder.updatedAt = updatedData.updatedAt
            managedFolder.title = updatedData.title
            managedFolder.image = updatedData.image
            
            try context.save()
            
            return .success(managedFolder.toDomainFolder())
        }
        
        do {
            
            return try await coreDataStore.perform(action)
        } catch {
            
            return .failure(.internalError(error))
        }
    }
}

// MARK: - Output Methods

extension CoreDataMediaLibraryRepository {
    
    private func getManagedItemDeprecated(id: UUID) async throws -> ManagedAudioFile?  {
        
        let request = ManagedAudioFile.fetchRequest()
        request.fetchLimit = 1
        request.resultType = .managedObjectResultType
        request.predicate = NSPredicate(
            format: "%K = %@",
            (\ManagedAudioFile.id)._kvcKeyPathString!,
            id.uuidString
        )
        
        let managedItems = try coreDataStore.performSync { context -> [ManagedAudioFile] in
            
            return try context.fetch(request)
        }
        
        return managedItems.first
    }
    
    private func getManagedItem(id: UUID, context: NSManagedObjectContext) throws -> ManagedLibraryItem?  {
        
        let request = ManagedLibraryItem.fetchRequest()
        request.fetchLimit = 1
        request.resultType = .managedObjectResultType
        request.predicate = NSPredicate(
            format: "%K = %@",
            (\ManagedLibraryItem.id)._kvcKeyPathString!,
            id.uuidString
        )
        
        return try context.fetch(request).first
    }
    
    private func getManagedItem(id: UUID) async throws -> ManagedLibraryItem?  {
        
        return try await coreDataStore.perform { context throws -> ManagedLibraryItem? in
 
            return try self.getManagedItem(id: id, context: context)
        }
    }
    
    public func getItem(id: UUID) async -> Result<MediaLibraryItem, MediaLibraryRepositoryError> {
        
        let action = { (context: NSManagedObjectContext) -> Result<MediaLibraryItem, MediaLibraryRepositoryError> in
            
            do {
                
                guard let managedItem = try self.getManagedItem(id: id, context: context) else {
                    return .failure(.fileNotFound)
                }
                
                return .success(managedItem.toDomain())
                
            } catch {
                
                return .failure(.internalError(error))
            }
            
        }
            
        do {
            
            return try await coreDataStore.perform(action)
            
        } catch {
            
            return .failure(.internalError(error))
        }
    }
    
    public func getRootFolderItem(context: NSManagedObjectContext) throws -> ManagedLibraryItem? {
        
        return try getManagedItem(id: ManagedLibraryItem.emptyId, context: context)
    }
    
    public func getRootFolderItemOrCreate(context: NSManagedObjectContext) throws -> ManagedLibraryItem? {
        
        if let rootFolder = try getManagedItem(id: ManagedLibraryItem.emptyId, context: context) {
            return rootFolder
        }

        let rootFolder = ManagedLibraryItem(context: context)
        
        rootFolder.id = ManagedLibraryItem.emptyId
        rootFolder.createdAt = .now
        rootFolder.title = ManagedLibraryItem.emptyId.uuidString
        rootFolder.isFolder = true
        
        rootFolder.children = NSMutableOrderedSet()
        
        if let rootFolder = try getManagedItem(id: ManagedLibraryItem.emptyId, context: context) {
            return rootFolder
        }
        
        return rootFolder
    }

    public func listItems(folderId: UUID?) async -> Result<[MediaLibraryItem], MediaLibraryRepositoryError> {

        let action = { (context: NSManagedObjectContext) throws -> [MediaLibraryItem] in
            
            
            let parentItem: ManagedLibraryItem?
            
            if let folderId = folderId {
                
                parentItem = try? self.getManagedItem(id: folderId, context: context)

            } else {
                
                guard
                    let rootItem = try? self.getRootFolderItem(context: context)
                else {
                    return []
                }
                
                parentItem = rootItem
            }
            
            guard
                let parentItem = parentItem,
                let children = parentItem.children
            else {
                return []
            }
            
            var result = [MediaLibraryItem]()
            
            for item in children{

                let managedItem = item as! ManagedLibraryItem
                result.append(managedItem.toDomain())
            }
            
            return result
        }
     
        do {
            
            let items = try await coreDataStore.perform(action)
            return .success(items)
            
        } catch {
            
            return .failure(.internalError(error))
        }
    }
}
