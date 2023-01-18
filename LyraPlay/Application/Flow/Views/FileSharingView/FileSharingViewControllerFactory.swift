//
//  FileSharingViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.01.2023.
//

import Foundation
import UIKit

public final class FileSharingViewControllerFactory: FileSharingViewFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func create(viewModel: FileSharingViewModel) -> FileSharingView {

        return FileSharingViewController(viewModel: viewModel)
    }
}
