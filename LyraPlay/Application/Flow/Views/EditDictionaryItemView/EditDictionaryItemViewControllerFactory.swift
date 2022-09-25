//
//  EditDictionaryItemViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation

public final class EditDictionaryItemViewControllerFactory: EditDictionaryItemViewFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func create(viewModel: EditDictionaryItemViewModel) -> EditDictionaryItemViewController {

        return EditDictionaryItemViewController(viewModel: viewModel)
    }
}
