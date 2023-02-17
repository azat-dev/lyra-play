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
    private let libraryFlowModelFactory: LibraryFolderFlowModelFactory
    private let dictionaryFlowModelFactory: DictionaryFlowModelFactory
    private let currentPlayerStateDetailsFlowModelFactory: CurrentPlayerStateDetailsFlowModelFactory

    // MARK: - Initializers

    public init(
        mainTabBarViewModelFactory: MainTabBarViewModelFactory,
        libraryFlowModelFactory: LibraryFolderFlowModelFactory,
        dictionaryFlowModelFactory: DictionaryFlowModelFactory,
        currentPlayerStateDetailsFlowModelFactory: CurrentPlayerStateDetailsFlowModelFactory
    ) {

        self.mainTabBarViewModelFactory = mainTabBarViewModelFactory
        self.libraryFlowModelFactory = libraryFlowModelFactory
        self.dictionaryFlowModelFactory = dictionaryFlowModelFactory
        self.currentPlayerStateDetailsFlowModelFactory = currentPlayerStateDetailsFlowModelFactory
    }

    // MARK: - Methods

    public func make() -> MainFlowModel {

        return MainFlowModelImpl(
            mainTabBarViewModelFactory: mainTabBarViewModelFactory,
            libraryFlowModelFactory: libraryFlowModelFactory,
            dictionaryFlowModelFactory: dictionaryFlowModelFactory,
            currentPlayerStateDetailsFlowModelFactory: currentPlayerStateDetailsFlowModelFactory
        )
    }
}
