//
//  PlayingNowService.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 02.07.22.
//

import Foundation
import MediaPlayer
import UIKit

// MARK: - Interfaces

public protocol NowPlayingInfoService {
    
    func update(from: MediaInfo)
    
    func update(currentTime: Double, rate: Float)
}


// MARK: - Implementations

public final class DefaultNowPlayingInfoService: NowPlayingInfoService {
    
    public func update(currentTime: Double, rate: Float) {
        
        let infoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = infoCenter.nowPlayingInfo ?? [String: Any]()
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = rate
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    
    public func update(from mediaInfo: MediaInfo) {

        var nowPlayingInfo = [String : Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = mediaInfo.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = mediaInfo.artist
        nowPlayingInfo[MPMediaItemPropertyPersistentID] = mediaInfo.id

        let image = UIImage(data: mediaInfo.coverImage)!
        
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
            return image
        }

        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = mediaInfo.duration
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
