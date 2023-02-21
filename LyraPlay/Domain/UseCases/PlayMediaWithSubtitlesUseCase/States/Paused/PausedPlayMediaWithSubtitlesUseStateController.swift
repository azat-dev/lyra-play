//
//  PausedPlayMediaWithSubtitlesUseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public protocol PausedPlayMediaWithSubtitlesUseStateController: PlayMediaWithSubtitlesUseStateController {
    
    func run() -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
}
