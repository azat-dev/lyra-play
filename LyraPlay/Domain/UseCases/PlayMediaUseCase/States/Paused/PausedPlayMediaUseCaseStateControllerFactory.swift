//
//  PausedPlayMediaUseCaseStateControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation

public protocol PausedPlayMediaUseCaseStateControllerFactories:
    InitialPlayMediaUseCaseStateControllerFactory,
    PlayingPlayMediaUseCaseStateControllerFactory,
    LoadingPlayMediaUseCaseStateControllerFactory {}

public protocol PausedPlayMediaUseCaseStateControllerFactory {
    
    func makePaused(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        context: PlayMediaUseCaseStateControllerContext
    ) -> PlayMediaUseCaseStateController
}
