//
//  LoadedPlayMediaUseCaseStateControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.02.23.
//

import Foundation

public protocol LoadedPlayMediaUseCaseStateControllerFactories:
    InitialPlayMediaUseCaseStateControllerFactory,
    LoadingPlayMediaUseCaseStateControllerFactory,
    PlayingPlayMediaUseCaseStateControllerFactory {}

public protocol LoadedPlayMediaUseCaseStateControllerFactory {
    
    func makeLoaded(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        context: PlayMediaUseCaseStateControllerContext
    ) -> PlayMediaUseCaseStateController
}
