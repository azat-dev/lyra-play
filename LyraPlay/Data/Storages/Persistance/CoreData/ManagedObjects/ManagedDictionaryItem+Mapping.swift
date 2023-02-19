//
//  ManagedDictionaryItem+Mapping.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.07.22.
//

import Foundation
import CoreData

struct TranslationItemPositionDTO: Codable {

    public var sentenceIndex: Int
    public var textRange: Range<Int>

    public init(
        sentenceIndex: Int,
        textRange: Range<Int>
    ) {

        self.sentenceIndex = sentenceIndex
        self.textRange = textRange
    }
    
    init(from item: TranslationItemPosition) {
        
        sentenceIndex = item.sentenceIndex
        textRange = item.textRange
    }
    
    func toDomain() -> TranslationItemPosition {
        
        return .init(
            sentenceIndex: sentenceIndex,
            textRange: textRange
        )
    }
}


struct TranslationItemDTO: Codable {

    var id: UUID?
    var text: String
    var mediaId: UUID?
    var timeMark: UUID?
    var position: TranslationItemPositionDTO?
    
    init(
        text: String,
        mediaId: UUID? = nil,
        timeMark: UUID? = nil,
        position: TranslationItemPositionDTO? = nil
    ) {
        self.text = text
        self.mediaId = mediaId
        self.timeMark = timeMark
        self.position = position
    }
    
    init(from item: TranslationItem) {
        
        id = item.id
        text = item.text
        mediaId = item.mediaId
        timeMark = item.timeMark
        
        if let position = item.position {
            self.position = .init(from: position)
        } else {
            self.position = nil
        }
    }
    
    func toDomain() -> TranslationItem {
        
        return .init(
            id: id,
            text: text,
            mediaId: mediaId,
            timeMark: timeMark,
            position: position?.toDomain()
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
    
    static func make(_ context: NSManagedObjectContext, from domain: DictionaryItem) -> ManagedDictionaryItem {

        let item = ManagedDictionaryItem(context: context)
        
        item.fillFields(from: domain)
        item.id = UUID()
        
        return item
    }
}
