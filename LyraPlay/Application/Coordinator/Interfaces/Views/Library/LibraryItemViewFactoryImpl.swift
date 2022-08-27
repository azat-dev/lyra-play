//
//  LibraryItemViewFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.08.22.
//

import Foundation

public final class LibraryItemViewFactoryImpl: LibraryItemViewFactory {
    
    public init() {}
    
    public func create(viewModel: LibraryItemViewModel) -> LibraryItemView {
        
        return LibraryItemViewController(viewModel: viewModel)
    }
}
