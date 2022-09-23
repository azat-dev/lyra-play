//
//  ManagedLibraryItem+CoreDataProperties.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.09.22.
//
//

import Foundation
import CoreData


extension ManagedLibraryItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedLibraryItem> {
        return NSFetchRequest<ManagedLibraryItem>(entityName: "ManagedLibraryItem")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var duration: Double
    @NSManaged public var file: String?
    @NSManaged public var genre: String?
    @NSManaged public var id: UUID?
    @NSManaged public var image: String?
    @NSManaged public var isFolder: Bool
    @NSManaged public var lastPlayedAt: Date?
    @NSManaged public var metaInfo: Data?
    @NSManaged public var playedTime: Double
    @NSManaged public var subtitle: String?
    @NSManaged public var title: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var children: NSOrderedSet?
    @NSManaged public var parent: ManagedLibraryItem?

}

// MARK: Generated accessors for children
extension ManagedLibraryItem {

    @objc(insertObject:inChildrenAtIndex:)
    @NSManaged public func insertIntoChildren(_ value: ManagedLibraryItem, at idx: Int)

    @objc(removeObjectFromChildrenAtIndex:)
    @NSManaged public func removeFromChildren(at idx: Int)

    @objc(insertChildren:atIndexes:)
    @NSManaged public func insertIntoChildren(_ values: [ManagedLibraryItem], at indexes: NSIndexSet)

    @objc(removeChildrenAtIndexes:)
    @NSManaged public func removeFromChildren(at indexes: NSIndexSet)

    @objc(replaceObjectInChildrenAtIndex:withObject:)
    @NSManaged public func replaceChildren(at idx: Int, with value: ManagedLibraryItem)

    @objc(replaceChildrenAtIndexes:withChildren:)
    @NSManaged public func replaceChildren(at indexes: NSIndexSet, with values: [ManagedLibraryItem])

    @objc(addChildrenObject:)
    @NSManaged public func addToChildren(_ value: ManagedLibraryItem)

    @objc(removeChildrenObject:)
    @NSManaged public func removeFromChildren(_ value: ManagedLibraryItem)

    @objc(addChildren:)
    @NSManaged public func addToChildren(_ values: NSOrderedSet)

    @objc(removeChildren:)
    @NSManaged public func removeFromChildren(_ values: NSOrderedSet)

}

extension ManagedLibraryItem : Identifiable {

}
