//
//  AudioFilesBrowserViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class AudioFilesBrowserViewControllerFactory: AudioFilesBrowserViewFactory {
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func create(viewModel: AudioFilesBrowserViewModel) -> AudioFilesBrowserView {
        
        return AudioFilesBrowserViewController(viewModel: viewModel)
    }
}
