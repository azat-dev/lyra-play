//
//  FinishedPlayMediaWithSubtitlesUseStateControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.02.23.
//

import Foundation

public protocol FinishedPlayMediaWithSubtitlesUseStateControllerFactory {
    
    func make(
        session: PlayMediaWithSubtitlesUseStateControllerActiveSession,
        delegate: PlayMediaWithSubtitlesUseStateControllerDelegate
    ) -> FinishedPlayMediaWithSubtitlesUseStateController
}
