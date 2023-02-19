//
//  LoadedPlayMediaWithSubtitlesUseStateControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public protocol LoadedPlayMediaWithSubtitlesUseStateControllerFactory {
    
    func make(
        session: PlayMediaWithSubtitlesUseStateControllerActiveSession,
        delegate: PlayMediaWithSubtitlesUseStateControllerDelegate
    ) -> LoadedPlayMediaWithSubtitlesUseStateController
}
