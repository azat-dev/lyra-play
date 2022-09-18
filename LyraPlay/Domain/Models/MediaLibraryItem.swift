//
//  MediaLibraryItem.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 18.09.22.
//

import Foundation

public enum MediaLibraryItem: Equatable {
    
    case file(MediaLibraryFile)
    case folder(MediaLibraryFolder)
}

public struct MediaLibraryFolder: Equatable {
    
    public let id: UUID
    public var parentId: UUID?
    public let createdAt: Date
    public let updatedAt: Date?
    public var title: String
    public var image: String?
    
    public init(
        id: UUID,
        parentId: UUID?,
        createdAt: Date,
        updatedAt: Date?,
        title: String,
        image: String?
    ) {
        
        self.id = id
        self.parentId = parentId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.title = title
        self.image = image
    }
}

public struct MediaLibraryFile: Equatable {
    
    public let id: UUID
    public var parentId: UUID?
    public let createdAt: Date
    public let updatedAt: Date?
    public var title: String
    public var subtitle: String
    public var file: String
    public var image: String?
    public var genre: String?
    public var duration: Double
    public var lastPlayedAt: Date?
    public var playedTime: Double

    public init(
        id: UUID,
        parentId: UUID?,
        createdAt: Date,
        updatedAt: Date?,
        title: String,
        subtitle: String,
        file: String,
        duration: Double,
        image: String?,
        genre: String?,
        lastPlayedAt: Date? = nil,
        playedTime: Double = 0
    ) {
        
        self.id = id
        self.parentId = parentId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.title = title
        self.subtitle = subtitle
        self.file = file
        self.image = image
        self.genre = genre
        self.duration = duration
        self.lastPlayedAt = lastPlayedAt
        self.playedTime = playedTime
    }
}
