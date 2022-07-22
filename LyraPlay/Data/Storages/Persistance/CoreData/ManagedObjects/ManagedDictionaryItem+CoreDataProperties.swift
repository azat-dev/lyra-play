//
//  ManagedDictionaryItem+CoreDataProperties.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.07.22.
//
//

import Foundation
import CoreData


extension ManagedDictionaryItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedDictionaryItem> {
        return NSFetchRequest<ManagedDictionaryItem>(entityName: "ManagedDictionaryItem")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var language: String?
    @NSManaged public var originalText: String?
    @NSManaged public var lemma: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var translations: Data?

}

extension ManagedDictionaryItem : Identifiable {

}
