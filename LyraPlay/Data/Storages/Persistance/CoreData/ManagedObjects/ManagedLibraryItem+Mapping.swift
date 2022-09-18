//
//  ManagedLibraryItem+Mapping.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 18.09.22.
//

import Foundation
import CoreData

extension ManagedLibraryItem {
    
    func toDomain() -> MediaLibraryItem {
        
        if isFolder {
            
            return .folder(
                .init(
                    id: id!,
                    createdAt: createdAt!,
                    updatedAt: updatedAt,
                    title: title!,
                    image: image
                )
            )
        }
        
        return .file(
            .init(
                id: id!,
                createdAt: createdAt!,
                updatedAt: updatedAt,
                title: title!,
                subtitle: subtitle!,
                file: file!,
                duration: duration,
                image: image,
                genre: genre,
                lastPlayedAt: lastPlayedAt,
                playedTime: playedTime
            )
        )
    }
}
