//
//  FinishedPlayMediaUseCaseStateControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation

public protocol FinishedPlayMediaUseCaseStateControllerFactory {
    
    func make(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        delegate: PlayMediaUseCaseStateControllerDelegate
    ) -> PlayMediaUseCaseStateController
}
