//
//  PlayerViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.06.22.
//

import Foundation

public final class PlayerViewControllerFactory {
    
    private var playMediaUseCase: PlayMediaUseCase
    
    init(playMediaUseCase: PlayMediaUseCase) {
        
        self.playMediaUseCase = playMediaUseCase
    }
    
    public func build() -> PlayerViewController {
        
        let viewModel = PlayerViewModelImpl(
            playMediaUseCase: playMediaUseCase
        )
        
        return PlayerViewController(viewModel: viewModel)
    }
}
