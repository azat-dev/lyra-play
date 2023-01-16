//
//  ManagedLibraryItem+Mapping.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 18.09.22.
//

import Foundation
import CoreData

extension ManagedLibraryItem {
    
    public static let emptyId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    
    func toDomainFile() -> MediaLibraryFile {
        
        guard !isFolder else {
            fatalError("ManagedLibraryItem is not a file")
        }
        
        return .init(
            id: id!,
            parentId: parent?.id,
            createdAt: createdAt!,
            updatedAt: updatedAt,
            title: title!,
            subtitle: subtitle,
            file: file!,
            duration: duration,
            image: image,
            genre: genre,
            lastPlayedAt: lastPlayedAt,
            playedTime: playedTime
        )
    }
    
    func toDomainFolder() -> MediaLibraryFolder {
        
        guard isFolder else {
            fatalError("ManagedLibraryItem is not a folder")
        }
        
        return .init(
            id: id!,
            parentId: parent?.id,
            createdAt: createdAt!,
            updatedAt: updatedAt,
            title: title!,
            image: image
        )
    }
    
    func toDomain() -> MediaLibraryItem {
        
        if isFolder {
            return .folder(toDomainFolder())
        }
        
        return .file(toDomainFile())
    }
}
