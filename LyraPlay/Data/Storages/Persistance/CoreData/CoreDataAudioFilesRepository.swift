//
//  DefaultAudioFilesRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 25.06.22.
//

import Foundation
import CoreData

// MARK: - Implementations

final class CoreDataAudioLibraryRepository: AudioLibraryRepository {
    
    private let coreDataStore: CoreDataStore
    
    public init(coreDataStore: CoreDataStore) {
        self.coreDataStore = coreDataStore
    }
    
    public func listFiles() async -> Result<[AudioFileInfo], AudioLibraryRepositoryError> {
        
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
    
    private func getManagedItem(id: UUID) async throws -> ManagedAudioFile?  {
        
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
    
    public func getInfo(fileId: UUID) async -> Result<AudioFileInfo, AudioLibraryRepositoryError> {
        
        
        do {
            let managedItem = try await getManagedItem(id: fileId)
            
            guard let item = managedItem?.toDomain() else {
                return .failure(.fileNotFound)
            }
            
            return .success(item)
            
        } catch {
            
            return .failure(.internalError(error))
        }
    }
    
    
    public func putFile(info file: AudioFileInfo) async -> Result<AudioFileInfo, AudioLibraryRepositoryError> {
        
        var existingFile: ManagedAudioFile? = nil
        
        if let fileId = file.id {
            existingFile = try? await getManagedItem(id: fileId)
            
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
            let domainItem: AudioFileInfo = updatedFile.toDomain()
            return .success(domainItem)

        } catch {
            return .failure(.internalError(error))
        }
    }
    
    public func delete(fileId: UUID) async -> Result<Void, AudioLibraryRepositoryError> {
        
        guard let managedFile = try? await getManagedItem(id: fileId) else {
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
