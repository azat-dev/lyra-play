//
//  LoadingPlayMediaUseCaseStateControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.02.23.
//

import Foundation

public protocol LoadingPlayMediaUseCaseStateControllerFactory {
    
    func make(
        mediaId: UUID,
        delegate: PlayMediaUseCaseStateControllerDelegate
    ) -> LoadingPlayMediaUseCaseStateController
}
