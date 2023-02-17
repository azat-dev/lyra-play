//
//  FailedLoadPlayMediaUseCaseStateControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation

public protocol FailedLoadPlayMediaUseCaseStateControllerFactory {
    
    func make(
        mediaId: UUID,
        delegate: PlayMediaUseCaseStateControllerDelegate
    ) -> FailedLoadPlayMediaUseCaseStateController
}
