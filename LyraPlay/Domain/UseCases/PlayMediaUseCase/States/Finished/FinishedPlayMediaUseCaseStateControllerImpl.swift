//
//  FinishedPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation

public class FinishedPlayMediaUseCaseStateControllerImpl: PausedPlayMediaUseCaseStateControllerImpl, FinishedPlayMediaUseCaseStateController {
    
    public override func play() -> Result<Void, PlayMediaUseCaseError> {
        return super.play(atTime: 0)
    }
}
