//
//  FileSharingViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 18.01.2023.
//

import Foundation

public final class FileSharingViewModelImplFactory: FileSharingViewModelFactory {

    // MARK: - Properties

    private let provideFileUrlUseCase: ProvideFileUrlUseCase

    // MARK: - Initializers

    public init(provideFileUrlUseCase: ProvideFileUrlUseCase) {

        self.provideFileUrlUseCase = provideFileUrlUseCase
    }

    // MARK: - Methods

    public func create(delegate: FileSharingViewModelDelegate) -> FileSharingViewModel {

        return FileSharingViewModelImpl(
            provideFileUrlUseCase: provideFileUrlUseCase,
            delegate: delegate
        )
    }
}