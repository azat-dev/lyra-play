//
//  DictionaryExporterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.01.23.
//

import Foundation

public class DictionaryExporterImpl: DictionaryExporter {
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    private func listItems(repository: DictionaryRepositoryOutputList, callback: @escaping (_ items: [ExportedDictionaryItem]?) -> Void) {
        
        DispatchQueue(label: "listItemsDictionaryExporter-\(UUID().uuidString)").async {
            Task {
                let result = await repository.listItems()
                
                guard case .success(let items) = result else {
                    callback(nil)
                    return
                }
                
                callback(items.map(ExportedDictionaryItem.init))
            }
        }
    }
    
    public func export(repository: DictionaryRepositoryOutputList) -> Result<[ExportedDictionaryItem], Error> {
        
        
        var exportedItems: [ExportedDictionaryItem]?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        self.listItems(repository: repository) { items in
            exportedItems = items
            semaphore.signal()
        }
        
        semaphore.wait()
        
        guard let exportedItems = exportedItems else {
            return .failure(NSError(domain: "InternalError", code: 0))
        }
        
        return .success(exportedItems)
    }
}

internal extension ExportedDictionaryItem {
    
    init(_ dictionaryItem: DictionaryItem) {
        
        self.init(
            original: dictionaryItem.originalText,
            translations: dictionaryItem.translations.map { $0.text }
        )
    }
}
