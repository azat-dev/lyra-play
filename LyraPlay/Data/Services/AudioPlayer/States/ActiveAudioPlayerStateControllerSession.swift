//
//  ActiveAudioPlayerStateControllerSession.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.02.23.
//

import Foundation
import AVFAudio

public struct ActiveAudioPlayerStateControllerSession {

    // MARK: - Properties
    
    public let fileId: String
    public let systemPlayer: AVAudioPlayer
    
    // MARK: - Initializers
    
    public init(fileId: String, systemPlayer: AVAudioPlayer) {
        self.fileId = fileId
        self.systemPlayer = systemPlayer
    }
}
