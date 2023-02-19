//
//  AttachingSubtitlesProgressViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation

public final class AttachingSubtitlesProgressViewControllerFactory: AttachingSubtitlesProgressViewFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func make(viewModel: AttachingSubtitlesProgressViewModel) -> AttachingSubtitlesProgressViewController {

        return AttachingSubtitlesProgressViewController(viewModel: viewModel)
    }
}
