//
//  LoadingPlayMediaWithSubtitlesUseStateControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public protocol LoadingPlayMediaWithSubtitlesUseStateControllerFactory {
    
    func make(
        params: PlayMediaWithSubtitlesSessionParams,
        delegate: PlayMediaWithSubtitlesUseStateControllerDelegate
    ) -> LoadingPlayMediaWithSubtitlesUseStateController
}
