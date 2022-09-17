//
//  Library+Helpers.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 15.09.22.
//

import Foundation
import LyraPlay

extension MediaLibraryItem {
    
    static func anyExistingItem() -> MediaLibraryItem {
        
        return MediaLibraryItem(
            id: UUID(),
            createdAt: .now,
            updatedAt: nil,
            name: UUID().uuidString,
            duration: 10,
            audioFile: "test.mp3",
            artist: "",
            coverImage: "test.png"
        )
    }
}
