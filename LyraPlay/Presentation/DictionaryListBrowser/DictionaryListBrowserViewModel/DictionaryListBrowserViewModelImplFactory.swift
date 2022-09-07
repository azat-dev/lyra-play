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

    public func create(delegate: DictionaryListBrowserViewModelDelegate) -> DictionaryListBrowserViewModel {

        return DictionaryListBrowserViewModelImpl(
            delegate: delegate,
            browseDictionaryUseCase: browseDictionaryUseCase
        )
    }
}
