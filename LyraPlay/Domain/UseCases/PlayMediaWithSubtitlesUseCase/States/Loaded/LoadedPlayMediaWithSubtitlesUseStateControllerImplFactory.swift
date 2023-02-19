//
//  LoadedPlayMediaWithSubtitlesUseStateControllerImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public final class LoadedPlayMediaWithSubtitlesUseStateImplControllerFactory: LoadedPlayMediaWithSubtitlesUseStateControllerFactory {

    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func make(
        session: PlayMediaWithSubtitlesUseStateControllerActiveSession,
        delegate: PlayMediaWithSubtitlesUseStateControllerDelegate
    ) -> LoadedPlayMediaWithSubtitlesUseStateController {
        
        return LoadedPlayMediaWithSubtitlesUseStateControllerImpl(
            session: session,
            delegate: delegate
        )
    }
}
