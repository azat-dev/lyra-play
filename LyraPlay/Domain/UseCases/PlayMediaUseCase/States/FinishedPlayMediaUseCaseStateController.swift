//
//  FinishedPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation

public final class FinishedPlayMediaUseCaseStateController: PausedPlayMediaUseCaseStateController {
    
    public override func togglePlay() -> Result<Void, PlayMediaUseCaseError> {
        return play(atTime: 0)
    }
}
