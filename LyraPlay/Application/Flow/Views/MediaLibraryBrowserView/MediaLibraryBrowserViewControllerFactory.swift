//
//  MediaLibraryBrowserViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class MediaLibraryBrowserViewControllerFactory: MediaLibraryBrowserViewFactory {
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func create(viewModel: MediaLibraryBrowserViewModel) -> MediaLibraryBrowserViewController {
        
        return MediaLibraryBrowserViewController(viewModel: viewModel)
    }
}
