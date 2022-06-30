//
//  PlayerViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.06.22.
//

import Foundation

public final class PlayerViewControllerFactory {
    
    private var audioPlayerUseCase: AudioPlayerUseCase
    
    init(audioPlayerUseCase: AudioPlayerUseCase) {
        
        self.audioPlayerUseCase = audioPlayerUseCase
    }
    
    public func build() -> PlayerViewController {
        
        let viewModel = DefaultPlayerViewModel(
            audioPlayerUseCase: audioPlayerUseCase
        )
        
        return PlayerViewController(viewModel: viewModel)
    }
}
