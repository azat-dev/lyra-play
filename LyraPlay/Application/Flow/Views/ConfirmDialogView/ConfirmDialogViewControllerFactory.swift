//
//  ConfirmDialogViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation

public final class ConfirmDialogViewControllerFactory: ConfirmDialogViewFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func make(viewModel: ConfirmDialogViewModel) -> ConfirmDialogViewController {

        return ConfirmDialogViewController.make(viewModel: viewModel)
    }
}
