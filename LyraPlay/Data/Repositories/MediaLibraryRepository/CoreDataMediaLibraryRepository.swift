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
        
        if let parentId = parentId {
            
            do {
                
                guard let parentItem = try await getManagedItem(id: parentId) else {
                    return .failure(.parentNotFound)
                }
                
                guard parentItem.isFolder else {
                    return .failure(.parentIsNotFolder)
                }
                
            } catch {
                return .failure(.internalError(error))
            }
        }
        
        let action = { (context: NSManagedObjectContext) throws -> ManagedLibraryItem in
            
            var newItem = ManagedLibraryItem(context: context)

            fillDTO(&newItem)
            
            newItem.id = UUID()
            newItem.createdAt = .now
            newItem.parentId = newItem.parentId ?? ManagedLibraryItem.emptyId

            try context.save()
            return newItem
        }
        
        do {
            
            let newItem = try coreDataStore.performSync(action)
            return .success(mapToDomainType(newItem))
            
        } catch {
            
            guard
                let conflictList = (error as NSError).userInfo["conflictList"] as? [NSConstraintConflict]
            else {
                return .failure(.internalError(error))
            }
            
            let isConflict = conflictList.contains { item in
                item.constraint.contains(#keyPath(ManagedLibraryItem.parentId)) &&
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
    
    private func getManagedItem(id: UUID) async throws -> ManagedLibraryItem?  {
        
        let request = ManagedLibraryItem.fetchRequest()
        request.fetchLimit = 1
        request.resultType = .managedObjectResultType
        request.predicate = NSPredicate(
            format: "%K = %@",
            (\ManagedAudioFile.id)._kvcKeyPathString!,
            id.uuidString
        )
        
        let managedItems = try coreDataStore.performSync { context -> [ManagedLibraryItem] in
            
            return try context.fetch(request)
        }
        
        return managedItems.first
    }
    
    public func getItem(id: UUID) async -> Result<MediaLibraryItem, MediaLibraryRepositoryError> {
        
        do {
            let managedItem = try await getManagedItem(id: id)
            
            guard let item = managedItem?.toDomain() else {
                return .failure(.fileNotFound)
            }
            
            return .success(item)
            
        } catch {
            
            return .failure(.internalError(error))
        }
    }
    
    public func listItems(folderId: UUID?) async -> Result<[MediaLibraryItem], MediaLibraryRepositoryError> {
        return .success([])
    }
}
