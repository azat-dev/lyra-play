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
    private let pronounceTextUseCaseFactory: PronounceTextUseCaseFactory
    private let dictionaryListBrowserItemViewModelFactory: DictionaryListBrowserItemViewModelFactory

    // MARK: - Initializers

    public init(
        browseDictionaryUseCase: BrowseDictionaryUseCase,
        pronounceTextUseCaseFactory: PronounceTextUseCaseFactory,
        dictionaryListBrowserItemViewModelFactory: DictionaryListBrowserItemViewModelFactory
    ) {

        self.browseDictionaryUseCase = browseDictionaryUseCase
        self.pronounceTextUseCaseFactory = pronounceTextUseCaseFactory
        self.dictionaryListBrowserItemViewModelFactory = dictionaryListBrowserItemViewModelFactory
    }

    // MARK: - Methods

    public func make(delegate: DictionaryListBrowserViewModelDelegate) -> DictionaryListBrowserViewModel {

        return DictionaryListBrowserViewModelImpl(
            delegate: delegate,
            dictionaryListBrowserItemViewModelFactory: dictionaryListBrowserItemViewModelFactory,
            browseDictionaryUseCase: browseDictionaryUseCase,
            pronounceTextUseCaseFactory: pronounceTextUseCaseFactory
        )
    }
}
