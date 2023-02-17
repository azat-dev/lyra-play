//
//  FilesPickerViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation

public final class FilesPickerViewControllerFactory: FilesPickerViewFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func make(viewModel: FilesPickerViewModel) -> FilesPickerViewController {

        return FilesPickerViewController(viewModel: viewModel)
    }
}
