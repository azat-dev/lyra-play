//
//  AudioFilesBrowserViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class AudioFilesBrowserViewControllerFactory: AudioFilesBrowserViewFactory {

    // MARK: - Properties

    private let viewModel: AudioFilesBrowserViewModel

    // MARK: - Initializers

    public init(viewModel: AudioFilesBrowserViewModel) {

        self.viewModel = viewModel
    }

    // MARK: - Methods

    public func create(viewModel: AudioFilesBrowserViewModel) -> AudioFilesBrowserView {

        return AudioFilesBrowserViewController(viewModel: viewModel)
    }
}