//
//  PlayMediaWithSubtitlesUseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 16.02.23.
//

import Foundation

public protocol PlayMediaWithSubtitlesUseStateController: PlayMediaWithSubtitlesUseCaseInput {
    
    var currentTime: TimeInterval { get }
    
    var duration: TimeInterval { get }
}
