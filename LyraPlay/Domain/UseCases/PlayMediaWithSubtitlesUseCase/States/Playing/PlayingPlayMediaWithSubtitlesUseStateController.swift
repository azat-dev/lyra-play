//
//  PlayingPlayMediaWithSubtitlesUseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public protocol PlayingPlayMediaWithSubtitlesUseStateController: PlayMediaWithSubtitlesUseStateController {
    
    func run() -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
}