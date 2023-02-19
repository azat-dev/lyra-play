//
//  PlayMediaUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation

public final class PlayMediaUseCaseImplFactory: PlayMediaUseCaseFactory {
    
    // MARK: - Properties
    
    private let initialStateFactory: InitialPlayMediaUseCaseStateControllerFactory
    private let loadingStateFactory: LoadingPlayMediaUseCaseStateControllerFactory
    private let loadedStateFactory: LoadedPlayMediaUseCaseStateControllerFactory
    private let failedLoadStateFactory: FailedLoadPlayMediaUseCaseStateControllerFactory
    private let playingStateFactory: PlayingPlayMediaUseCaseStateControllerFactory
    private let pausedStateFactory: PausedPlayMediaUseCaseStateControllerFactory
    private let finishedStateFactory: FinishedPlayMediaUseCaseStateControllerFactory
    
    // MARK: - Initializers
    
    public init(
        initialStateFactory: InitialPlayMediaUseCaseStateControllerFactory,
        loadingStateFactory: LoadingPlayMediaUseCaseStateControllerFactory,
        loadedStateFactory: LoadedPlayMediaUseCaseStateControllerFactory,
        failedLoadStateFactory: FailedLoadPlayMediaUseCaseStateControllerFactory,
        playingStateFactory: PlayingPlayMediaUseCaseStateControllerFactory,
        pausedStateFactory: PausedPlayMediaUseCaseStateControllerFactory,
        finishedStateFactory: FinishedPlayMediaUseCaseStateControllerFactory
    ) {
        
        self.initialStateFactory = initialStateFactory
        self.loadingStateFactory = loadingStateFactory
        self.loadedStateFactory = loadedStateFactory
        self.failedLoadStateFactory = failedLoadStateFactory
        self.playingStateFactory = playingStateFactory
        self.pausedStateFactory = pausedStateFactory
        self.finishedStateFactory = finishedStateFactory
    }

    // MARK: - Methods
    
    public func make() -> PlayMediaUseCase {
        
        return PlayMediaUseCaseImpl(
            initialStateFactory: initialStateFactory,
            loadingStateFactory: loadingStateFactory,
            loadedStateFactory: loadedStateFactory,
            failedLoadStateFactory: failedLoadStateFactory,
            playingStateFactory: playingStateFactory,
            pausedStateFactory: pausedStateFactory,
            finishedStateFactory: finishedStateFactory
        )
    }
}
