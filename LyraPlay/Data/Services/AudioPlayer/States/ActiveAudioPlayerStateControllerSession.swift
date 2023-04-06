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
    public let systemPlayer: SystemPlayer
    
    // MARK: - Initializers
    
    public init(fileId: String, systemPlayer: SystemPlayer) {
        self.fileId = fileId
        self.systemPlayer = systemPlayer
    }
}
