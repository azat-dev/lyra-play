//
//  ManagedDictionaryItem+Mapping.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.07.22.
//

import Foundation
import CoreData

extension ManagedDictionaryItem {
    
    func toDomain() -> DictionaryItem {
        
        return DictionaryItem(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            originalText: originalText!,
            language: language!
        )
    }
    
    func fillFields(from source: DictionaryItem) {

        id = source.id
        createdAt = source.createdAt
        updatedAt = source.updatedAt
        originalText = source.originalText
        language = source.language
    }
    
    static func create(_ context: NSManagedObjectContext, from domain: DictionaryItem) -> ManagedDictionaryItem {

        let item = ManagedDictionaryItem(context: context)
        
        item.id = UUID()
        item.fillFields(from: domain)
        
        return item
    }
}
