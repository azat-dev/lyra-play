//
//  LoadedPlayMediaUseCaseStateControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.02.23.
//

import Foundation

public protocol LoadedPlayMediaUseCaseStateControllerFactory {
    
    func make(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        delegate: PlayMediaUseCaseStateControllerDelegate
    ) -> PlayMediaUseCaseStateController
}
