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
    private let libraryFlowModelFactory: LibraryFolderFlowModelFactory
    private let dictionaryFlowModelFactory: DictionaryFlowModelFactory
    private let currentPlayerStateDetailsFlowModelFactory: CurrentPlayerStateDetailsFlowModelFactory
    
    public var libraryFlow: CurrentValueSubject<LibraryFolderFlowModel?, Never> = .init(nil)
    public var dictionaryFlow: CurrentValueSubject<DictionaryFlowModel?, Never> = .init(nil)
    public var currentPlayerStateDetailsFlow: CurrentValueSubject<CurrentPlayerStateDetailsFlowModel?, Never> = .init(nil)

    public lazy var mainTabBarViewModel: MainTabBarViewModel = {
        
        return mainTabBarViewModelFactory.make(delegate: self)
    } ()

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
        
        libraryFlow.value = libraryFlowModelFactory.make(folderId: nil)
    }
    
    public func runDictionaryFlow() {
        
        if dictionaryFlow.value != nil {
            return
        }
        
        dictionaryFlow.value = dictionaryFlowModelFactory.make()
    }
    
    public func runOpenCurrentPlayerStateDetailsFlow() {
        
        if currentPlayerStateDetailsFlow.value != nil {
            return
        }
        
        currentPlayerStateDetailsFlow.value = currentPlayerStateDetailsFlowModelFactory.make(delegate: self)
    }
}

// MARK: - CurrentPlayerStateDetailsFlowModelDelegate

extension MainFlowModelImpl: CurrentPlayerStateDetailsFlowModelDelegate {
    
    public func currentPlayerStateDetailsFlowModelDidDispose() {
        
        currentPlayerStateDetailsFlow.value = nil
    }
}
