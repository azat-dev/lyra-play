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

    // MARK: - Initializers

    public init(
        delegate: MainTabBarViewModelDelegate,
        currentPlayerStateViewModelFactory: CurrentPlayerStateViewModelFactory
    ) {

        self.delegate = delegate
        self.currentPlayerStateViewModelFactory = currentPlayerStateViewModelFactory
        
        currentPlayerStateViewModel.value = currentPlayerStateViewModelFactory.create(delegate: self)
    }
}

// MARK: - Input Methods

extension MainTabBarViewModelImpl {

    public func selectLibraryTab() -> Void {

        delegate?.runLibraryFlow()
    }

    public func selectDictionaryTab() -> Void {

        delegate?.runDictionaryFlow()
    }
}

// MARK: - Output Methods

extension MainTabBarViewModelImpl: CurrentPlayerStateViewModelDelegate {

    public func currentPlayerStateViewModelDidOpen() {
        
        delegate?.runOpenCurrentPlayerStateDetailsFlow()
    }
}
