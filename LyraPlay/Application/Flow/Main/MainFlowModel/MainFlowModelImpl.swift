//
//  MainFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation
import Combine

public final class MainFlowModelImpl: MainFlowModel {

    // MARK: - Properties

    private let mainTabBarViewModelFactory: MainTabBarViewModelFactory
    private let libraryFlowModelFactory: LibraryFlowModelFactory
    public var libraryFlow: CurrentValueSubject<LibraryFlowModel?, Never> = .init(nil)

    public lazy var mainTabBarViewModel: MainTabBarViewModel = {
        
        return mainTabBarViewModelFactory.create(delegate: self)
    } ()

    // MARK: - Initializers

    public init(
        mainTabBarViewModelFactory: MainTabBarViewModelFactory,
        libraryFlowModelFactory: LibraryFlowModelFactory
    ) {

        self.mainTabBarViewModelFactory = mainTabBarViewModelFactory
        self.libraryFlowModelFactory = libraryFlowModelFactory
    }
}

// MARK: - Input Methods

extension MainFlowModelImpl {

    public func openDeepLink(link: DeepLink) {

        fatalError()
    }
}

// MARK: - MainTabBarViewModelDelegate

extension MainFlowModelImpl: MainTabBarViewModelDelegate {
    
    public func runLibraryFlow() {
        
        if libraryFlow.value != nil {
            return
        }
        
        libraryFlow.value = libraryFlowModelFactory.create()
    }
    
    public func runDictionaryFlow() {
        
    }
}
