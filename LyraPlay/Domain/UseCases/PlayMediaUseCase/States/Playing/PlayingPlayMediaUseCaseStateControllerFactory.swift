//
//  PlayingPlayMediaUseCaseStateControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation

public protocol PlayingPlayMediaUseCaseStateControllerFactories:
    InitialPlayMediaUseCaseStateControllerFactory,
    LoadingPlayMediaUseCaseStateControllerFactory,
    PausedPlayMediaUseCaseStateControllerFactory {}

public protocol PlayingPlayMediaUseCaseStateControllerFactory {
    
    func makePlaying(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        context: PlayMediaUseCaseStateControllerContext
    ) -> PlayMediaUseCaseStateController
}
