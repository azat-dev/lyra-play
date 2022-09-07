//
//  LibraryFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation

public final class LibraryFlowModelImplFactory: LibraryFlowModelFactory {

    // MARK: - Properties

    private let viewModelFactory: AudioFilesBrowserViewModelFactory

    // MARK: - Initializers

    public init(viewModelFactory: AudioFilesBrowserViewModelFactory) {

        self.viewModelFactory = viewModelFactory
    }

    // MARK: - Methods

    public func create() -> LibraryFlowModel {

        return LibraryFlowModelImpl(viewModelFactory: viewModelFactory)
    }
}