//
//  AudioFileInfo.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 24.06.22.
//

import Foundation

struct AudioFileInfo {
    
    var id: UUID?
    var createdAt: Date
    var updatedAt: Date?
    var name: String
    var artist: String?
    var genre: String?
}
