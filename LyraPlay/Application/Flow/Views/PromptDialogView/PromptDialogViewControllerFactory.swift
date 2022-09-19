//
//  PromptDialogViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation

public final class PromptDialogViewControllerFactory: PromptDialogViewFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func create(viewModel: PromptDialogViewModel) -> PromptDialogViewController {

        return PromptDialogViewController.create(viewModel: viewModel)
    }
}
