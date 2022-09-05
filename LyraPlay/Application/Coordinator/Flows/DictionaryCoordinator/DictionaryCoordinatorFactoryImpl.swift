//
//  DictionaryCoordinatorFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

public final class DictionaryCoordinatorFactoryImpl: DictionaryCoordinatorFactory {

    // MARK: - Properties

    private let viewModelFactory: DictionaryListBrowserViewModelFactory
    private let viewFactory: DictionaryListBrowserViewFactory

    // MARK: - Initializers

    public init(
        viewModelFactory: DictionaryListBrowserViewModelFactory,
        viewFactory: DictionaryListBrowserViewFactory
    ) {

        self.viewModelFactory = viewModelFactory
        self.viewFactory = viewFactory
    }

    // MARK: - Methods

    public func create() -> DictionaryCoordinator {

        return DictionaryCoordinatorImpl(
            viewModelFactory: viewModelFactory,
            viewFactory: viewFactory
        )
    }
}