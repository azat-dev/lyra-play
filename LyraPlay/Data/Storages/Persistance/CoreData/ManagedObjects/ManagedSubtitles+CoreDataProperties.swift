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

    @NSManaged public var file: String?
    @NSManaged public var language: String?
    @NSManaged public var mediaFileId: UUID?

}

extension ManagedSubtitles : Identifiable {

}
