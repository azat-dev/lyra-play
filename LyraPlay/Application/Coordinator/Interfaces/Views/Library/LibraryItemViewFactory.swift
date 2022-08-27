//
//  LibraryItemViewFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.08.22.
//

import Foundation

public protocol LibraryItemViewFactory: AnyObject {
    
    func create(viewModel: LibraryItemViewModel) -> LibraryItemView
}
