//
//  InitialPlayMediaWithSubtitlesUseStateControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public protocol InitialPlayMediaWithSubtitlesUseStateControllerFactory {
    
    func make(delegate: PlayMediaWithSubtitlesUseStateControllerDelegate) -> InitialPlayMediaWithSubtitlesUseStateController
}
