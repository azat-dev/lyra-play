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
    public var duration: Double
    public var genre: String?
    public var coverImage: String?
    public var audioFile: String
    
    init(
        id: UUID?,
        createdAt: Date?,
        updatedAt: Date?,
        name: String,
        duration: Double,
        audioFile: String,
        artist: String? = nil,
        genre: String? = nil,
        coverImage: String? = nil
    ) {
        
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.artist = artist
        self.genre = genre
        self.coverImage = coverImage
        self.audioFile = audioFile
        self.duration = duration
    }
}

public extension AudioFileInfo {
    
    static func create(name: String, duration: Double, audioFile: String) -> AudioFileInfo {
        
        return AudioFileInfo(
            id: nil,
            createdAt: nil,
            updatedAt: nil,
            name: name,
            duration: duration,
            audioFile: audioFile
        )
    }
}
