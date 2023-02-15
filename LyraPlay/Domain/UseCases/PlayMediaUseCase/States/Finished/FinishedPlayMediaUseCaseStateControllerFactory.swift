//
//  FinishedPlayMediaUseCaseStateControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation

public protocol FinishedPlayMediaUseCaseStateControllerFactories: PausedPlayMediaUseCaseStateControllerFactories {}

public protocol FinishedPlayMediaUseCaseStateControllerFactory {
    
    func makeFinished(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        context: PlayMediaUseCaseStateControllerContext
    ) -> PlayMediaUseCaseStateController
}
