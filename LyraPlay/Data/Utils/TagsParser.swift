//
//  TagsParser.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.06.22.
//

import Foundation
import AVFoundation
import UIKit

// MARK: - Interfaces

public struct TagsImageData {

    public var data: Data
    public var fileExtension: String
    
    public init(data: Data, fileExtension: String) {
        self.data = data
        self.fileExtension = fileExtension
    }
}

public struct AudioFileTags {
    
    public var title: String?
    public var genre: String?
    public var coverImage: TagsImageData?
    public var artist: String?
    public var duration: Double
    public var lyrics: String?
    public var jsonSubtitles: String?
    
    public init(
        title: String? = nil,
        genre: String? = nil,
        coverImage: TagsImageData? = nil,
        artist: String? = nil,
        duration: Double,
        lyrics: String? = nil,
        jsonSubtitles: String? = nil
    ) {
        
        self.title = title
        self.genre = genre
        self.coverImage = coverImage
        self.artist = artist
        self.lyrics = lyrics
        self.duration = duration
        self.jsonSubtitles = jsonSubtitles
    }
}

public protocol TagsParser {
    func parse(url: URL) async -> Result<AudioFileTags, Error>
}

// MARK: - Implementations

public final class TagsParserImpl: TagsParser {
    
    public init() {}
    
    public func parse(url: URL) async -> Result<AudioFileTags, Error> {
        
        let asset = AVAsset(url: url)
        
        let titleMeta = asset.metadata.first { $0.commonKey == .commonKeyTitle }
        let artworkMeta = asset.metadata.first { $0.commonKey == .commonKeyArtwork }
        let artistMeta = asset.metadata.first { $0.commonKey == .commonKeyArtist }
        let genreMeta = asset.metadata.first { $0.commonKey == .commonKeyType }
        
        let jsonSubtitlesMeta = asset.metadata.first { item in
            
            guard
                let key = item.key as? String,
                key == "TXXX",
                let infoName = item.extraAttributes?[.info] as? String,
                infoName == "json_subtitles"
            else {
                return false
            }

            return true
        }
        
        var coverImage: TagsImageData?
        
        if let artworkMeta = artworkMeta {
            coverImage = TagsImageData(
                data: UIImage(data: artworkMeta.dataValue!)!.pngData()!,
                fileExtension: "png"
            )
        }
        
        let tags = AudioFileTags(
            title: titleMeta?.stringValue,
            genre: genreMeta?.stringValue,
            coverImage: coverImage,
            artist: artistMeta?.stringValue,
            duration: CMTimeGetSeconds(asset.duration),
            lyrics: asset.lyrics,
            jsonSubtitles: jsonSubtitlesMeta?.stringValue
        )
        
        return .success(tags)
    }
}
