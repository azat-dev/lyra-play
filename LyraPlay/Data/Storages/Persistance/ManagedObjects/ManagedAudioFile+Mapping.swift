//
//  ManagedAudioFile+Mapping.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.06.22.
//

import Foundation
import CoreData

extension ManagedAudioFile {
    
    func toDomain() -> AudioFileInfo {
        return AudioFileInfo(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            name: name,
            artist: artist,
            genre: genre
        )
    }
    
    func fillFields(from source: AudioFileInfo) {
        
        self.name = source.name
        self.artist = source.artist
        self.genre = source.genre
        self.createdAt = source.createdAt
        self.updatedAt = source.updatedAt
    }
    
    static func create(_ context: NSManagedObjectContext, from domain: AudioFileInfo) -> ManagedAudioFile {

        let item = ManagedAudioFile(context: context)
        
        item.id = UUID()
        item.fillFields(from: domain)
        
        return item
    }
}
