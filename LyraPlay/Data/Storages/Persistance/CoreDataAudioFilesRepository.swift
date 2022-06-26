//
//  DefaultAudioFilesRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 25.06.22.
//

import Foundation
import CoreData

// MARK: - Implementations

final class CoreDataAudioFilesRepository: AudioFilesRepository {
    
    private let coreDataStore: CoreDataStore
    
    public init(coreDataStore: CoreDataStore) {
        self.coreDataStore = coreDataStore
    }
    
    public func listFiles() async -> Result<[AudioFileInfo], AudioFilesRepositoryError> {
        
        let request = ManagedAudioFile.fetchRequest()

        do {
            let managedItems = try await coreDataStore.performSync { context -> Result<[ManagedAudioFile], Error> in
                
                do {
                    let result = try context.fetch(request)
                    return .success(result)
                } catch {
                    return .failure(error)
                }
            }
            
            let domainItems = managedItems.map { $0.toDomain() }
            
            return .success(domainItems)
            
        } catch {
            
            return .failure(.internalError)
        }
    }
    
    private func getManagedItem(id: UUID) async throws -> ManagedAudioFile?  {
        
        let request = ManagedAudioFile.fetchRequest()
        request.fetchLimit = 1
        request.resultType = .managedObjectResultType
        request.predicate = NSPredicate(format: "%K = %@", "id", id.uuidString)

        do {
            let managedItems = try await coreDataStore.performSync { context -> Result<[ManagedAudioFile], Error> in
                
                do {
                    let result = try context.fetch(request)
                    return .success(result)
                } catch {
                    return .failure(error)
                }
            }
            
            return managedItems.first
            
        } catch {
            throw error
        }
    }
    
    public func getInfo(fileId: UUID) async -> Result<AudioFileInfo, AudioFilesRepositoryError> {
        

        do {
            let managedItem = try await getManagedItem(id: fileId)
            
            guard let item = managedItem?.toDomain() else {
                return .failure(.fileNotFound)
            }
            
            return .success(item)
            
        } catch {
            
            return .failure(.internalError)
        }
    }
    
    
    public func putFile(info file: AudioFileInfo, data: Data) async -> Result<AudioFileInfo, AudioFilesRepositoryError> {
        
        var existingFile: ManagedAudioFile? = nil
        
        if let fileId = file.id {
            existingFile = try? await getManagedItem(id: fileId)
            
            if existingFile == nil {
                return .failure(.fileNotFound)
            }
        }
        
        let updatedFile = try! await coreDataStore.performSync { context -> Result<AudioFileInfo, Error> in
            
            var updatedFile: ManagedAudioFile!
            
            if let existingFile = existingFile {
            
                existingFile.fillFields(from: file)
                updatedFile = existingFile
            
            } else {
                
                let newFile = ManagedAudioFile.create(context, from: file)
                newFile.fillFields(from: file)
                updatedFile = newFile
            }
            
            updatedFile.updatedAt = .now
            
            try! context.save()
            let domainItem: AudioFileInfo = updatedFile.toDomain()
            
            return .success(domainItem)
        }
        
        return .success(updatedFile)
        
    }
    
    public func delete(fileId: UUID) async -> Result<Void, AudioFilesRepositoryError> {
        
        guard let managedFile = try? await getManagedItem(id: fileId) else {
            return .failure(.fileNotFound)
        }
        
        try! await coreDataStore.performSync { context -> Result<Void, Error> in
            context.delete(managedFile)
            try! context.save()
            
            return .success(())
        }
        
        return .success(())
    }
}
