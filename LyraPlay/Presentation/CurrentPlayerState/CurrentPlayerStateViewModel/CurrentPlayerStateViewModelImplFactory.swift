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
    
    // MARK: - Initializers
    
    public init(playMediaUseCaseFactory: PlayMediaWithInfoUseCaseFactory) {
        
        self.playMediaUseCaseFactory = playMediaUseCaseFactory
    }
    
    // MARK: - Methods
    
    public func create(delegate: CurrentPlayerStateViewModelDelegate) -> CurrentPlayerStateViewModel {
        
        let playMediaUseCase = playMediaUseCaseFactory.create()
        
        return CurrentPlayerStateViewModelImpl(
            delegate: delegate,
            playMediaUseCase: playMediaUseCase
        )
    }
}
