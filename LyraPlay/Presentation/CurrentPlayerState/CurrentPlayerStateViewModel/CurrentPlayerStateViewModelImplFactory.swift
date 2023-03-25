//
//  CurrentPlayerStateViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation

public final class CurrentPlayerStateViewModelImplFactory: CurrentPlayerStateViewModelFactory {
    
    // MARK: - Properties
    
    private let playMediaUseCaseFactory: PlayMediaWithInfoUseCaseFactory
    private let getLastPlayedMediaUseCaseFactory: GetLastPlayedMediaUseCaseFactory
    private let showMediaInfoUseCaseFactory: ShowMediaInfoUseCaseFactory
    
    // MARK: - Initializers
    
    public init(
        playMediaUseCaseFactory: PlayMediaWithInfoUseCaseFactory,
        getLastPlayedMediaUseCaseFactory: GetLastPlayedMediaUseCaseFactory,
        showMediaInfoUseCaseFactory: ShowMediaInfoUseCaseFactory
    ) {
        
        self.playMediaUseCaseFactory = playMediaUseCaseFactory
        self.getLastPlayedMediaUseCaseFactory = getLastPlayedMediaUseCaseFactory
        self.showMediaInfoUseCaseFactory = showMediaInfoUseCaseFactory
    }
    
    // MARK: - Methods
    
    public func make(delegate: CurrentPlayerStateViewModelDelegate) -> CurrentPlayerStateViewModel {
        
        let playMediaUseCase = playMediaUseCaseFactory.make()
        
        return CurrentPlayerStateViewModelImpl(
            delegate: delegate,
            playMediaUseCase: playMediaUseCase,
            getLastPlayedMediaUseCaseFactory: getLastPlayedMediaUseCaseFactory,
            showMediaInfoUseCaseFactory: showMediaInfoUseCaseFactory
        )
    }
}
