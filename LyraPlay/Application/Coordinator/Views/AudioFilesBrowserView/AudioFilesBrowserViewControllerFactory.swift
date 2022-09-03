//
//  AudioFilesBrowserViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class AudioFilesBrowserViewControllerFactory<ViewModel>: AudioFilesBrowserViewFactory where ViewModel: AudioFilesBrowserViewModel {
    
    // MARK: - Types
    
    public typealias View = AudioFilesBrowserViewController
    
    public typealias ViewModel = ViewModel
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func create(viewModel: ViewModel) -> View {
        
        return AudioFilesBrowserViewController(viewModel: viewModel)
    }
}
