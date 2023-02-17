//
//  MediaLibraryBrowserViewFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.2022.
//

public protocol MediaLibraryBrowserViewFactory {
    
    func make(viewModel: MediaLibraryBrowserViewModel) -> MediaLibraryBrowserViewController
}
