//
//  LibraryItemViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

import Foundation

public final class LibraryItemViewControllerFactory: LibraryItemViewFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func create(viewModel: LibraryItemViewModel) -> LibraryItemView {

        return LibraryItemViewController(viewModel: viewModel)
    }
}