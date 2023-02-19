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

    public func make(viewModel: PromptDialogViewModel) -> PromptDialogViewController {

        return PromptDialogViewController(viewModel: viewModel)
    }
}
