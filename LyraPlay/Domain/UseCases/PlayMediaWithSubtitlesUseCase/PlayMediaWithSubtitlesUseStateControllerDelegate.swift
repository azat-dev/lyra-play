//
//  PlayMediaWithSubtitlesUseStateControllerContext.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 16.02.23.
//

import Foundation

public protocol PlayMediaWithSubtitlesUseStateControllerDelegate: AnyObject {
    
    func didStartLoading(params: PlayMediaWithSubtitlesSessionParams)
}
