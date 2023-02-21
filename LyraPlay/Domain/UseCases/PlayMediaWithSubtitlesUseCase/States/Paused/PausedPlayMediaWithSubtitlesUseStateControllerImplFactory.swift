//
//  PausedPlayMediaWithSubtitlesUseStateControllerImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.02.23.
//

import Foundation

public final class PausedPlayMediaWithSubtitlesUseStateImplControllerFactory: PausedPlayMediaWithSubtitlesUseStateControllerFactory {

    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func make(
        session: PlayMediaWithSubtitlesUseStateControllerActiveSession,
        delegate: PlayMediaWithSubtitlesUseStateControllerDelegate
    ) -> PausedPlayMediaWithSubtitlesUseStateController {
        
        return PausedPlayMediaWithSubtitlesUseStateControllerImpl(
            session: session,
            delegate: delegate
        )
    }
}