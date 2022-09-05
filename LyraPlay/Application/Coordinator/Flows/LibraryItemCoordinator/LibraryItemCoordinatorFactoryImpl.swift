//
//  LibraryItemCoordinatorFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

public final class LibraryItemCoordinatorFactoryImpl: LibraryItemCoordinatorFactory {

    // MARK: - Properties

    private let viewModelFactory: LibraryItemViewModelFactory
    private let viewFactory: LibraryItemViewFactory

    // MARK: - Initializers

    public init(
        viewModelFactory: LibraryItemViewModelFactory,
        viewFactory: LibraryItemViewFactory
    ) {

        self.viewModelFactory = viewModelFactory
        self.viewFactory = viewFactory
    }

    // MARK: - Methods

    public func create() -> LibraryItemCoordinator {

        return LibraryItemCoordinatorImpl(
            viewModelFactory: viewModelFactory,
            viewFactory: viewFactory
        )
    }
}