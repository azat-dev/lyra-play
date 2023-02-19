//
//  AudioPlayerStateControllerContext.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.02.23.
//

import Foundation

public protocol AudioPlayerStateControllerContext: AnyObject {
    
    func setController(_ currenStateController: AudioPlayerStateController)
    
    func activateAudioSession()
    
    func deactivateAudioSession()
}
