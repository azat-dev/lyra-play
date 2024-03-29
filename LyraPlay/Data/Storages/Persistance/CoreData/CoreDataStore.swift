//
//  CoreDataStore.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 25.06.22.
//

import Foundation
import CoreData

public class CoreDataStore {
    
    public typealias ActionCallBack<R> = (_ context: NSManagedObjectContext) throws -> R
    
    private static let modelName = "LyraPlay"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    public init(storeURL: URL) throws {
        guard let model = CoreDataStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: CoreDataStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }
    
    func performSync<R>(_ action: ActionCallBack<R>) throws -> R {

        let context = self.context
        var result: Result<R, Error>!
        
        context.performAndWait {
            
            do {
                let actionResult = try action(context)
                result = .success(actionResult)
            } catch {
                result = .failure(error)
            }
        }
        
        return try result.get()
    }
    
    func perform<R>(_ action: @escaping ActionCallBack<R>) async throws -> R {

        return try await container.performBackgroundTask { context in
            
            do {
                
                return try action(context)
                
            } catch {
                
                context.reset()
                throw error
            }
        }
    }
}


extension NSPersistentContainer {
    static func load(name: String, model: NSManagedObjectModel, url: URL) throws -> NSPersistentContainer {
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw $0 }
        
        return container
    }
}

extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}
