//
//  PlayingPlayMediaWithSubtitlesUseStateImplControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public final class PlayingPlayMediaWithSubtitlesUseStateImplControllerFactory: PlayingPlayMediaWithSubtitlesUseStateControllerFactory {

    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func make(
        session: PlayMediaWithSubtitlesUseStateControllerActiveSession,
        delegate: PlayMediaWithSubtitlesUseStateControllerDelegate
    ) -> PlayingPlayMediaWithSubtitlesUseStateController {
        
        return PlayingPlayMediaWithSubtitlesUseStateControllerImpl(
            session: session,
            delegate: delegate
        )
    }
}
