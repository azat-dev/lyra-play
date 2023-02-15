//
//  LoadingPlayMediaUseCaseStateControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.02.23.
//

import Foundation

public protocol LoadingPlayMediaUseCaseStateControllerFactories:
    LoadingPlayMediaUseCaseStateControllerFactory,
    LoadedPlayMediaUseCaseStateControllerFactory,
    FailedLoadPlayMediaUseCaseStateControllerFactory
    {}

public protocol LoadingPlayMediaUseCaseStateControllerFactory {
    
    func makeLoading(
        mediaId: UUID,
        context: PlayMediaUseCaseStateControllerContext
    ) -> PlayMediaUseCaseStateController
}
