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
    
    public func putFile(info file: MediaLibraryAudioFile) async -> Result<MediaLibraryAudioFile, MediaLibraryRepositoryError> {
        
        var existingFile: ManagedAudioFile? = nil
        
        if let fileId = file.id {
            existingFile = try? await getManagedItemDeprecated(id: fileId)
            
            if existingFile == nil {
                return .failure(.fileNotFound)
            }
        }
        
        let action = { (context: NSManagedObjectContext) throws -> ManagedAudioFile in
            
            var updatedFile: ManagedAudioFile!
            
            if let existingFile = existingFile {
                
                existingFile.fillFields(from: file)
                updatedFile = existingFile
                updatedFile.updatedAt = .now
                
            } else {
                
                let newFile = ManagedAudioFile.create(context, from: file)
                newFile.fillFields(from: file)
                newFile.createdAt = .now
                updatedFile = newFile
            }
            
            try context.save()
            return updatedFile
        }
        
        do {
            
            let updatedFile = try coreDataStore.performSync(action)
            let domainItem: MediaLibraryAudioFile = updatedFile.toDomain()
            return .success(domainItem)
            
        } catch {
            return .failure(.internalError(error))
        }
    }
    
    private func createItem<DomainType>(
        parentId: UUID?,
        fillDTO: (inout ManagedLibraryItem) -> Void,
        mapToDomainType: (ManagedLibraryItem) -> DomainType
    ) async -> Result<DomainType, MediaLibraryRepositoryError> {
        
        
        let action = { (context: NSManagedObjectContext) throws -> ManagedLibraryItem in
            
            var parentItem: ManagedLibraryItem!

            if let parentId = parentId {
                
                guard let parent = try self.getManagedItem(id: parentId) else {
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
            return newItem
        }
        
        do {
            
            let newItem = try coreDataStore.performSync(action)
            return .success(mapToDomainType(newItem))
            
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
    
    public func delete(fileId: UUID) async -> Result<Void, MediaLibraryRepositoryError> {
        
        guard let managedFile = try? await getManagedItemDeprecated(id: fileId) else {
            return .failure(.fileNotFound)
        }
        
        let action = { (context: NSManagedObjectContext) throws -> Void in
            
            context.delete(managedFile)
            try context.save()
        }
        
        do {
            
            try coreDataStore.performSync(action)
        } catch {
            return .failure(.internalError(error))
        }
        
        return .success(())
    }
    
    public func deleteItem(id: UUID) async -> Result<Void, MediaLibraryRepositoryError> {
        
        guard let managedFile = try? getManagedItem(id: id) else {
            return .failure(.fileNotFound)
        }
        
        let action = { (context: NSManagedObjectContext) throws -> Void in
            
            context.delete(managedFile)
            try context.save()
        }
        
        do {
            
            try coreDataStore.performSync(action)
        } catch {
            return .failure(.internalError(error))
        }
        
        return .success(())
    }
    
    public func updateFile(data: MediaLibraryFile) async -> Result<MediaLibraryFile, MediaLibraryRepositoryError> {
        
        var updatedData = data
        updatedData.updatedAt = .now
        
        let action = { (context: NSManagedObjectContext) throws -> Void in
            
            guard let managedFile = try self.getManagedItem(id: updatedData.id, context: context) else {
                
                throw MediaLibraryRepositoryError.fileNotFound
            }
            
            guard !managedFile.isFolder else {
                throw MediaLibraryRepositoryError.internalError(nil)
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
        }
        
        do {
            
            try coreDataStore.performSync(action)
        } catch {
            
            if let error = error as? MediaLibraryRepositoryError {
                return .failure(error)
            }
            
            return .failure(.internalError(error))
        }
        
        return .success(updatedData)
    }
    
    public func updateFolder(data: MediaLibraryFolder) async -> Result<MediaLibraryFolder, MediaLibraryRepositoryError> {
        
        var updatedData = data
        updatedData.updatedAt = .now
        
        let action = { (context: NSManagedObjectContext) throws -> Void in
            
            guard let managedFolder = try self.getManagedItem(id: updatedData.id, context: context) else {
                
                throw MediaLibraryRepositoryError.fileNotFound
            }
            
            guard managedFolder.isFolder else {
                throw MediaLibraryRepositoryError.internalError(nil)
            }
            
            managedFolder.updatedAt = updatedData.updatedAt
            managedFolder.title = updatedData.title
            managedFolder.image = updatedData.image
            
            try context.save()
        }
        
        do {
            
            try coreDataStore.performSync(action)
        } catch {
            
            if let error = error as? MediaLibraryRepositoryError {
                return .failure(error)
            }
            
            return .failure(.internalError(error))
        }
        
        return .success(updatedData)
    }
}

// MARK: - Output Methods

extension CoreDataMediaLibraryRepository {
    
    public func listFiles() async -> Result<[MediaLibraryAudioFile], MediaLibraryRepositoryError> {
        
        let request = ManagedAudioFile.fetchRequest()
        
        do {
            let managedItems = try coreDataStore.performSync { context -> [ManagedAudioFile] in
                
                return try context.fetch(request)
            }
            
            let domainItems = managedItems.map { $0.toDomain() }
            return .success(domainItems)
            
        } catch {
            
            return .failure(.internalError(error))
        }
    }
    
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
    
    public func getInfo(fileId: UUID) async -> Result<MediaLibraryAudioFile, MediaLibraryRepositoryError> {
        
        
        do {
            let managedItem = try await getManagedItemDeprecated(id: fileId)
            
            guard let item = managedItem?.toDomain() else {
                return .failure(.fileNotFound)
            }
            
            return .success(item)
            
        } catch {
            
            return .failure(.internalError(error))
        }
    }
    
    private func getManagedItem(id: UUID, context: NSManagedObjectContext) throws -> ManagedLibraryItem?  {
        
        let request = ManagedLibraryItem.fetchRequest()
        request.fetchLimit = 1
        request.resultType = .managedObjectResultType
        request.predicate = NSPredicate(
            format: "%K = %@",
            (\ManagedAudioFile.id)._kvcKeyPathString!,
            id.uuidString
        )
        
        return try context.fetch(request).first
    }
    
    private func getManagedItem(id: UUID) throws -> ManagedLibraryItem?  {
        
        return try coreDataStore.performSync { context throws -> ManagedLibraryItem? in
 
            return try getManagedItem(id: id, context: context)
        }
    }
    
    public func getItem(id: UUID) async -> Result<MediaLibraryItem, MediaLibraryRepositoryError> {
        
        do {
            let managedItem = try getManagedItem(id: id)
            
            guard let item = managedItem?.toDomain() else {
                return .failure(.fileNotFound)
            }
            
            return .success(item)
            
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
        return rootFolder
    }

    public func listItems(folderId: UUID?) async -> Result<[MediaLibraryItem], MediaLibraryRepositoryError> {

        let action = { (context: NSManagedObjectContext) throws -> [MediaLibraryItem] in
            
            
            let parentItem: ManagedLibraryItem?
            
            if let folderId = folderId {
                
                parentItem = try? self.getManagedItem(id: folderId)

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
            
            let items = try coreDataStore.performSync(action)
            return .success(items)
            
        } catch {
            
            return .failure(.internalError(error))
        }
    }
}
