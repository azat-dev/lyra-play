//
//  DictionaryListBrowserViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

import Foundation

public final class DictionaryListBrowserViewModelImplFactory: DictionaryListBrowserViewModelFactory {

    // MARK: - Properties

    private let browseDictionaryUseCase: BrowseDictionaryUseCase

    // MARK: - Initializers

    public init(browseDictionaryUseCase: BrowseDictionaryUseCase) {

        self.browseDictionaryUseCase = browseDictionaryUseCase
    }

    // MARK: - Methods

    public func create(coordinator: DictionaryCoordinatorInput) -> DictionaryListBrowserViewModel {

        return DictionaryListBrowserViewModelImpl(
            coordinator: coordinator,
            browseDictionaryUseCase: browseDictionaryUseCase
        )
    }
}