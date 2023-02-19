//
//  MainTabBarViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.2022.
//

import Foundation
import Combine

public final class MainTabBarViewModelImpl: MainTabBarViewModel {

    // MARK: - Properties

    private weak var delegate: MainTabBarViewModelDelegate?
    
    private let currentPlayerStateViewModelFactory: CurrentPlayerStateViewModelFactory
    
    public var currentPlayerStateViewModel = CurrentValueSubject<CurrentPlayerStateViewModel?, Never>(nil)
    
    public var activeTabIndex: CurrentValueSubject<Int, Never>

    // MARK: - Initializers

    public init(
        delegate: MainTabBarViewModelDelegate,
        currentPlayerStateViewModelFactory: CurrentPlayerStateViewModelFactory
    ) {

        self.delegate = delegate
        self.currentPlayerStateViewModelFactory = currentPlayerStateViewModelFactory
        self.activeTabIndex = .init(MainTabBarViewModelTab.library.rawValue)
        
        currentPlayerStateViewModel.value = currentPlayerStateViewModelFactory.make(delegate: self)
    }
}

// MARK: - Input Methods

extension MainTabBarViewModelImpl {

    public func selectLibraryTab() -> Void {

        activeTabIndex.value = MainTabBarViewModelTab.library.rawValue
        delegate?.runLibraryFlow()
    }

    public func selectDictionaryTab() -> Void {

        activeTabIndex.value = MainTabBarViewModelTab.dictionary.rawValue
        delegate?.runDictionaryFlow()
    }
}

// MARK: - Output Methods

extension MainTabBarViewModelImpl: CurrentPlayerStateViewModelDelegate {

    public func currentPlayerStateViewModelDidOpen() {
        
        delegate?.runOpenCurrentPlayerStateDetailsFlow()
    }
}
