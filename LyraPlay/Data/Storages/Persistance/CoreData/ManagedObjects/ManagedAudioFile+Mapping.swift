//
//  ManagedAudioFile+Mapping.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.06.22.
//

import Foundation
import CoreData

extension ManagedAudioFile {
    
    func toDomain() -> MediaLibraryAudioFile {
        return MediaLibraryAudioFile(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            name: name,
            duration: duration,
            audioFile: audioFile,
            artist: artist,
            genre: genre,
            coverImage: coverImage
        )
    }
    
    func fillFields(from source: MediaLibraryAudioFile) {
        
        self.name = source.name
        self.artist = source.artist
        self.genre = source.genre
        self.createdAt = source.createdAt
        self.updatedAt = source.updatedAt
        self.coverImage = source.coverImage
        self.audioFile = source.audioFile
        self.duration = source.duration
    }
    
    static func make(_ context: NSManagedObjectContext, from domain: MediaLibraryAudioFile) -> ManagedAudioFile {

        let item = ManagedAudioFile(context: context)
        
        item.id = UUID()
        item.fillFields(from: domain)
        
        return item
    }
}
