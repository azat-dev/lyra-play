//
//  FinishedPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation

public class FinishedPlayMediaUseCaseStateControllerImpl: PausedPlayMediaUseCaseStateControllerImpl, FinishedPlayMediaUseCaseStateController {
    
    public override func play(atTime: TimeInterval) {
        super.play(atTime: 0)
    }
}
