//
//  AudioFileInfo.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 24.06.22.
//

import Foundation

public struct AudioFileInfo {
    
    public var id: UUID?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var name: String
    public var artist: String?
    public var genre: String?
    
    init(id: UUID?, createdAt: Date?, updatedAt: Date?, name: String, artist: String?, genre: String?) {
        
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.artist = artist
        self.genre = genre
    }
}

public extension AudioFileInfo {
    
    static func create(name: String) -> AudioFileInfo {
        
        return AudioFileInfo(
            id: nil,
            createdAt: nil,
            updatedAt: nil,
            name: name,
            artist: nil,
            genre: nil
        )
    }
}
