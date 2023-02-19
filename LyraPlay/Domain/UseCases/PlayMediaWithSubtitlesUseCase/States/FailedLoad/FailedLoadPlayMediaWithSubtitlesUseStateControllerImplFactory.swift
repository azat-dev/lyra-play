//
//  FailedLoadPlayMediaWithSubtitlesUseStateControllerImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public final class FailedLoadPlayMediaWithSubtitlesUseStateControllerImplFactory: FailedLoadPlayMediaWithSubtitlesUseStateControllerFactory {
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func make(
        params: PlayMediaWithSubtitlesSessionParams,
        delegate: PlayMediaWithSubtitlesUseStateControllerDelegate
    ) -> FailedLoadPlayMediaWithSubtitlesUseStateController {
        
        return FailedLoadPlayMediaWithSubtitlesUseStateControllerImpl(
            delegate: delegate
        )
    }
}
