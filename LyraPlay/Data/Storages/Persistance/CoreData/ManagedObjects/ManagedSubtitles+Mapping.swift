//
//  ManagedSubtitles+Mapping.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.07.22.
//

import Foundation
import CoreData

extension ManagedSubtitles {
    
    func toDomain() -> SubtitlesInfo {
        return SubtitlesInfo(
            id: id,
            mediaFileId: mediaFileId,
            language: language,
            file: file
        )
    }
    
    func fillFields(from source: SubtitlesInfo) {
        
        self.mediaFileId = mediaFileId
        self.language = language
        self.file = file
    }
    
    static func create(_ context: NSManagedObjectContext, from domain: SubtitlesInfo) -> ManagedSubtitles {

        let item = ManagedSubtitles(context: context)
        
        item.id = UUID()
        item.fillFields(from: domain)
        
        return item
    }
}
