//
//  MainFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation

public final class MainFlowModelImplFactory: MainFlowModelFactory {

    // MARK: - Properties

    private let mainTabBarViewModelFactory: MainTabBarViewModelFactory
    private let libraryFlowModelFactory: LibraryFlowModelFactory
    private let dictionaryFlowModelFactory: DictionaryFlowModelFactory

    // MARK: - Initializers

    public init(
        mainTabBarViewModelFactory: MainTabBarViewModelFactory,
        libraryFlowModelFactory: LibraryFlowModelFactory,
        dictionaryFlowModelFactory: DictionaryFlowModelFactory
    ) {

        self.mainTabBarViewModelFactory = mainTabBarViewModelFactory
        self.libraryFlowModelFactory = libraryFlowModelFactory
        self.dictionaryFlowModelFactory = dictionaryFlowModelFactory
    }

    // MARK: - Methods

    public func create() -> MainFlowModel {

        return MainFlowModelImpl(
            mainTabBarViewModelFactory: mainTabBarViewModelFactory,
            libraryFlowModelFactory: libraryFlowModelFactory,
            dictionaryFlowModelFactory: dictionaryFlowModelFactory
        )
    }
}
