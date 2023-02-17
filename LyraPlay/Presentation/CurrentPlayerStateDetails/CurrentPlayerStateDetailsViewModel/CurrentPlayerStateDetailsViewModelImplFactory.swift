//
//  CurrentPlayerStateDetailsViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

import Foundation

public final class CurrentPlayerStateDetailsViewModelImplFactory: CurrentPlayerStateDetailsViewModelFactory {
    
    // MARK: - Properties
    
    private let playMediaUseCaseFactory: PlayMediaWithInfoUseCaseFactory
    private let subtitlesPresenterViewModelFactory: SubtitlesPresenterViewModelFactory
    
    // MARK: - Initializers
    
    public init(
        playMediaUseCaseFactory: PlayMediaWithInfoUseCaseFactory,
        subtitlesPresenterViewModelFactory: SubtitlesPresenterViewModelFactory
    ) {
        
        self.playMediaUseCaseFactory = playMediaUseCaseFactory
        self.subtitlesPresenterViewModelFactory = subtitlesPresenterViewModelFactory
    }
    
    // MARK: - Methods
    
    public func make(delegate: CurrentPlayerStateDetailsViewModelDelegate) -> CurrentPlayerStateDetailsViewModel {
        
        let playMediaUseCase = playMediaUseCaseFactory.make()
        
        return CurrentPlayerStateDetailsViewModelImpl(
            delegate: delegate,
            playMediaUseCase: playMediaUseCase,
            subtitlesPresenterViewModelFactory: subtitlesPresenterViewModelFactory
        )
    }
}
