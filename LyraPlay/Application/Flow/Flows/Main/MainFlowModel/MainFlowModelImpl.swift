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
    private let dictionaryFlowModelFactory: DictionaryFlowModelFactory
    
    public var libraryFlow: CurrentValueSubject<LibraryFlowModel?, Never> = .init(nil)
    public var dictionaryFlow: CurrentValueSubject<DictionaryFlowModel?, Never> = .init(nil)

    public lazy var mainTabBarViewModel: MainTabBarViewModel = {
        
        return mainTabBarViewModelFactory.create(delegate: self)
    } ()

    // MARK: - Initializers

    public init(
        mainTabBarViewModelFactory: MainTabBarViewModelFactory,
        libraryFlowModelFactory: LibraryFlowModelFactory,
        dictionaryFlowModelFactory: DictionaryFlowModelFactory
    ) {

        self.mainTabBarViewModelFactory = mainTabBarViewModelFactory
        self.libraryFlowModelFactory = libraryFlowModelFactory
        self.dictionaryFlowModelFactory = dictionaryFlowModelFactory
        
        runLibraryFlow()
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
        
        if dictionaryFlow.value != nil {
            return
        }
        
        dictionaryFlow.value = dictionaryFlowModelFactory.create()
    }
}
