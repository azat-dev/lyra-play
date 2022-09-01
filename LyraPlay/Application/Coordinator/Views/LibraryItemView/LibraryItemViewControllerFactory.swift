//
//  LibraryItemViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class LibraryItemViewControllerFactory: LibraryItemViewFactory {

    // MARK: - Properties

    private let viewModel: LibraryItemViewModel

    // MARK: - Initializers

    public init(viewModel: LibraryItemViewModel) {

        self.viewModel = viewModel
    }

    // MARK: - Methods

    public func create(viewModel: LibraryItemViewModel) -> LibraryItemView {

        return LibraryItemViewController(viewModel: viewModel)
    }
}