//
//  FileSharingViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.01.2023.
//

import Foundation

public final class FileSharingViewModelImplFactory: FileSharingViewModelFactory {

    // MARK: - Properties

    private let url: URL

    // MARK: - Initializers

    public init(url: URL) {

        self.url = url
    }

    // MARK: - Methods

    public func create(delegate: FileSharingViewModelDelegate) -> FileSharingViewModel {

        return FileSharingViewModelImpl(
            url: url,
            delegate: delegate
        )
    }
}
