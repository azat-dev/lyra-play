//
//  ManagedSubtitles+CoreDataProperties.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.07.22.
//
//

import Foundation
import CoreData


extension ManagedSubtitles {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedSubtitles> {
        return NSFetchRequest<ManagedSubtitles>(entityName: "ManagedSubtitles")
    }

    @NSManaged public var id: UUID
    @NSManaged public var mediaFileId: UUID
    @NSManaged public var language: String
    @NSManaged public var file: String

}

extension ManagedSubtitles : Identifiable {

}
