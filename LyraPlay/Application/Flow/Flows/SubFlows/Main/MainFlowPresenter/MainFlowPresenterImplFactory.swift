//
//  MainFlowPresenterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.01.23.
//

import Foundation

public class MainFlowPresenterImplFactory: MainFlowPresenterFactory {
    
    // MARK: - Properties
    
    private let mainTabBarViewFactory: MainTabBarViewFactory
    private let libraryFlowPresenterFactory: LibraryFolderFlowPresenterFactory
    private let dictionaryFlowPresenterFactory: DictionaryFlowPresenterFactory
    private let currentPlayerStateDetailsFlowPresenterFactory: CurrentPlayerStateDetailsFlowPresenterFactory
    
    // MARK: - Initializers
    
    public init(
        mainTabBarViewFactory: MainTabBarViewFactory,
        libraryFlowPresenterFactory: LibraryFolderFlowPresenterFactory,
        dictionaryFlowPresenterFactory: DictionaryFlowPresenterFactory,
        currentPlayerStateDetailsFlowPresenterFactory: CurrentPlayerStateDetailsFlowPresenterFactory
    ) {
        
        self.mainTabBarViewFactory = mainTabBarViewFactory
        self.libraryFlowPresenterFactory = libraryFlowPresenterFactory
        self.dictionaryFlowPresenterFactory = dictionaryFlowPresenterFactory
        self.currentPlayerStateDetailsFlowPresenterFactory = currentPlayerStateDetailsFlowPresenterFactory
    }
    
    // MARK: - Methods
    
    public func create(flowModel: MainFlowModel) -> MainFlowPresenter {
        
        return MainFlowPresenterImpl(
            mainFlowModel: flowModel,
            mainTabBarViewFactory: mainTabBarViewFactory,
            libraryFlowPresenterFactory: libraryFlowPresenterFactory,
            dictionaryFlowPresenterFactory: dictionaryFlowPresenterFactory,
            currentPlayerStateDetailsFlowPresenterFactory: currentPlayerStateDetailsFlowPresenterFactory
        )
    }
}
