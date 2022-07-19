//
//  ManagedDictionaryItem+CoreDataProperties.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.07.22.
//
//

import Foundation
import CoreData


extension ManagedDictionaryItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedDictionaryItem> {
        return NSFetchRequest<ManagedDictionaryItem>(entityName: "ManagedDictionaryItem")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var originalText: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var language: String?

}

extension ManagedDictionaryItem : Identifiable {

}
