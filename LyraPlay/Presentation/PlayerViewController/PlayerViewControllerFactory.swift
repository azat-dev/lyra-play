//
//  PlayerViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.06.22.
//

import Foundation

public final class PlayerViewControllerFactory {
    
    private var playerControlUseCase: PlayerControlUseCase
    
    init(playerControlUseCase: PlayerControlUseCase) {
        
        self.playerControlUseCase = playerControlUseCase
    }
    
    public func build() -> PlayerViewController {
        
        let viewModel = DefaultPlayerViewModel(
            playerControlUseCase: playerControlUseCase
        )
        
        return PlayerViewController(viewModel: viewModel)
    }
}
