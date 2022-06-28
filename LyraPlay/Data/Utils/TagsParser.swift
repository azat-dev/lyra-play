//
//  TagsParser.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.06.22.
//

import Foundation
import ID3TagEditor

// MARK: - Interfaces

public struct AudioFileTags {
    
    public var title: String?
    public var genre: String?
    public var coverImage: Data?
    public var artist: String?
    public var lyrics: String?
    
    public init(
        title: String? = nil,
        genre: String? = nil,
        coverImage: Data? = nil,
        artist: String? = nil,
        lyrics: String? = nil
    ) {
        
        self.title = title
        self.genre = genre
        self.coverImage = coverImage
        self.artist = artist
        self.lyrics = lyrics
    }
}

public protocol TagsParser {
    func parse(data: Data) async -> Result<AudioFileTags?, Error>
}

// MARK: - Implementations

public final class DefaultTagsParser: TagsParser {
    
    public init() {}
    
    public func parse(data: Data) async -> Result<AudioFileTags?, Error> {
        
        let id3TagEditor = ID3TagEditor()
        
        var tags: ID3Tag? = nil
        
        do {
            tags = try id3TagEditor.read(mp3: data)
        } catch {
            return .failure(NSError(domain: "Can't read tags", code: 0))
        }
        
        guard let tags = tags else {
            return .success(nil)
        }

        
        let tagsContentReader = ID3TagContentReader(id3Tag: tags)
        let coverData = tagsContentReader.attachedPictures().first(where: { $0.type == .frontCover })
        
        let resultTags = AudioFileTags(
            title: tagsContentReader.title(),
            genre: tagsContentReader.genre()?.description,
            coverImage: coverData?.picture,
            artist: tagsContentReader.artist(),
            lyrics: tagsContentReader.unsynchronizedLyrics().first?.content
        )
        
        return .success(resultTags)
    }
}
