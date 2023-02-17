//
//  DictionaryListBrowserViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

import Foundation

public final class DictionaryListBrowserViewControllerFactory: DictionaryListBrowserViewFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func make(viewModel: DictionaryListBrowserViewModel) -> DictionaryListBrowserViewController {

        return DictionaryListBrowserViewController(viewModel: viewModel)
    }
}
