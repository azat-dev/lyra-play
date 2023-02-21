//
//  FinishedPlayMediaWithSubtitlesUseStateControllerImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.02.23.
//

import Foundation

public final class FinishedPlayMediaWithSubtitlesUseStateImplControllerFactory: FinishedPlayMediaWithSubtitlesUseStateControllerFactory {

    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func make(
        session: PlayMediaWithSubtitlesUseStateControllerActiveSession,
        delegate: PlayMediaWithSubtitlesUseStateControllerDelegate
    ) -> FinishedPlayMediaWithSubtitlesUseStateController {
        
        return FinishedPlayMediaWithSubtitlesUseStateControllerImpl(
            session: session,
            delegate: delegate
        )
    }
}
