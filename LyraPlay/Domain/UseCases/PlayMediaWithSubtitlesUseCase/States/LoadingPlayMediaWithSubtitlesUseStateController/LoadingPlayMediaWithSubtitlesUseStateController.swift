//
//  LoadingPlayMediaWithSubtitlesUseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public protocol LoadingPlayMediaWithSubtitlesUseStateController {
 
    func load() async -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
}
