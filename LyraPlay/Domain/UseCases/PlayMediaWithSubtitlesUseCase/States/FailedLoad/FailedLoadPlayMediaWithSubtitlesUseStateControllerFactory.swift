//
//  FailedLoadPlayMediaWithSubtitlesUseStateControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public protocol FailedLoadPlayMediaWithSubtitlesUseStateControllerFactory {
    
    func make(
        params: PlayMediaWithSubtitlesSessionParams,
        delegate: PlayMediaWithSubtitlesUseStateControllerDelegate
    ) -> FailedLoadPlayMediaWithSubtitlesUseStateController
}
