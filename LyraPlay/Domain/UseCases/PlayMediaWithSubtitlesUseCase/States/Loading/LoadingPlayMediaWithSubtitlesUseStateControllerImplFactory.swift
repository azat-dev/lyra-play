//
//  LoadingPlayMediaWithSubtitlesUseStateControllerImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public class LoadingPlayMediaWithSubtitlesUseStateControllerImplFactory: LoadingPlayMediaWithSubtitlesUseStateControllerFactory {
    
    // MARK: - Properties
    
    private let playMediaUseCaseFactory: PlayMediaUseCaseFactory
    private let loadSubtitlesUseCaseFactory: LoadSubtitlesUseCaseFactory
    private let playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory
    
    // MARK: - Initializers
    
    public init(
        playMediaUseCaseFactory: PlayMediaUseCaseFactory,
        loadSubtitlesUseCaseFactory: LoadSubtitlesUseCaseFactory,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory
    ) {
        
        self.playMediaUseCaseFactory = playMediaUseCaseFactory
        self.loadSubtitlesUseCaseFactory = loadSubtitlesUseCaseFactory
        self.playSubtitlesUseCaseFactory = playSubtitlesUseCaseFactory
    }
    
    // MARK: - Methods
    
    public func make(
        params: PlayMediaWithSubtitlesSessionParams,
        delegate: PlayMediaWithSubtitlesUseStateControllerDelegate
    ) -> LoadingPlayMediaWithSubtitlesUseStateController {
        
        return LoadingPlayMediaWithSubtitlesUseStateControllerImpl(
            params: params,
            delegate: delegate,
            playMediaUseCaseFactory: playMediaUseCaseFactory,
            loadSubtitlesUseCaseFactory: loadSubtitlesUseCaseFactory,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory
        )
    }
}
