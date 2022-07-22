//
//  ManagedDictionaryItem+Mapping.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.07.22.
//

import Foundation
import CoreData

struct TranslationItemDTO: Codable {

    var text: String
    var mediaId: UUID?
    var timeMark: UUID?
    var position: String?
    
    init(
        text: String,
        mediaId: UUID? = nil,
        timeMark: UUID? = nil,
        position: String? = nil
    ) {
        self.text = text
        self.mediaId = mediaId
        self.timeMark = timeMark
        self.position = position
    }
    
    init(from item: TranslationItem) {
        
        text = item.text
        mediaId = item.mediaId
        timeMark = item.timeMark
        position = item.position
    }
    
    func toDomain() -> TranslationItem {
        
        return .init(
            text: text,
            mediaId: mediaId,
            timeMark: timeMark,
            position: position
        )
    }
    
    static func decode(from data: Data?) -> [TranslationItem] {
        
        guard let data = data else {
            return []
        }
        
        let decoder = JSONDecoder()
        let dtoItems = try? decoder.decode(Array<TranslationItemDTO>.self, from: data)
        
        return dtoItems?.map { $0.toDomain() } ?? []
    }
    
    static func encode(from items: [TranslationItem]) -> Data? {
        
        if items.isEmpty {
            return nil
        }
        
        let encoder = JSONEncoder()
        return try? encoder.encode(items.map { TranslationItemDTO(from: $0) })
    }

}

extension ManagedDictionaryItem {
    
    func toDomain() -> DictionaryItem {
        
        return DictionaryItem(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            originalText: originalText!,
            lemma: lemma!,
            language: language!,
            translations: TranslationItemDTO.decode(from: translations)
        )
    }
    
    func fillFields(from source: DictionaryItem) {

        createdAt = source.createdAt
        updatedAt = source.updatedAt
        originalText = source.originalText
        lemma = source.lemma
        language = source.language
        translations = TranslationItemDTO.encode(from: source.translations)
    }
    
    static func create(_ context: NSManagedObjectContext, from domain: DictionaryItem) -> ManagedDictionaryItem {

        let item = ManagedDictionaryItem(context: context)
        
        item.fillFields(from: domain)
        item.id = UUID()
        
        return item
    }
}
