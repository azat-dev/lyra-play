//
//  SubtitlesPickerViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation

public final class SubtitlesPickerViewControllerFactory: SubtitlesPickerViewFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func create(viewModel: SubtitlesPickerViewModel) -> SubtitlesPickerViewController {

        return SubtitlesPickerViewController(viewModel: viewModel)
    }
}
