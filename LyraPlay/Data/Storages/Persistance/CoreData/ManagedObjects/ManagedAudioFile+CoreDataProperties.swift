//
//  ManagedAudioFile+CoreDataProperties.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.06.22.
//
//

import Foundation
import CoreData


extension ManagedAudioFile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedAudioFile> {
        return NSFetchRequest<ManagedAudioFile>(entityName: "ManagedAudioFile")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var artist: String?
    @NSManaged public var genre: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

}

extension ManagedAudioFile : Identifiable {

}
