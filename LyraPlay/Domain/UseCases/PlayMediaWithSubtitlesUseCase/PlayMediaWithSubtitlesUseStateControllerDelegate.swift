//
//  PlayMediaWithSubtitlesUseStateControllerContext.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 16.02.23.
//

import Foundation


public protocol PlayMediaWithSubtitlesUseStateControllerDelegateLoading: AnyObject {
    
    func loading(params: PlayMediaWithSubtitlesSessionParams)
}

public protocol PlayMediaWithSubtitlesUseStateControllerDelegate:
    PlayMediaWithSubtitlesUseStateControllerDelegateLoading {}
