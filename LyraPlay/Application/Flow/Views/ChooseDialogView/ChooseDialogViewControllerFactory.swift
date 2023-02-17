//
//  ChooseDialogViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation

public final class ChooseDialogViewControllerFactory: ChooseDialogViewFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func make(viewModel: ChooseDialogViewModel) -> ChooseDialogViewController {

        return ChooseDialogViewController.make(viewModel: viewModel)
    }
}
