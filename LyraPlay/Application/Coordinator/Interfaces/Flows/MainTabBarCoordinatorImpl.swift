//
//  MainTabBarCoordinatorImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.22.
//

import Foundation

public final class MainTabBarCoordinatorImpl: BaseCoordinator, MainTabBarCoordinator {

    // MARK: - Properties
    
    private weak var mainTabBarView: MainTabBarView?

    private let mainTabBarViewModelFactory: MainTabBarViewModelFactory
    private let mainTabBarViewFactory: MainTabBarViewFactory
    private let libraryCoordinatorFactory: LibraryCoordinatorFactory

    // MARK: - Initializers
    
    public init(
        mainTabBarViewModelFactory: MainTabBarViewModelFactory,
        mainTabBarViewFactory: MainTabBarViewFactory,
        libraryCoordinatorFactory: LibraryCoordinatorFactory
    ) {
        
        self.mainTabBarViewModelFactory = mainTabBarViewModelFactory
        self.mainTabBarViewFactory = mainTabBarViewFactory
        self.libraryCoordinatorFactory = libraryCoordinatorFactory
        
        super.init()
    }
    
    // MARK: - Methods
    
    public func start(at container: StackPresentationContainer) {
        
        let viewModel = mainTabBarViewModelFactory.create(coordinator: self)
        let tabBarView = mainTabBarViewFactory.create(viewModel: viewModel)

        self.mainTabBarView = tabBarView
        container.setRoot(tabBarView)
    }
}

// MARK: - Input Methods

extension MainTabBarCoordinatorImpl {
    
    public func runLibraryFlow() {
        
        guard
            let mainTabBarView = mainTabBarView,
            !children.contains(where: { $0 is LibraryCoordinator })
        else {
            return
        }
        
        let libraryCoordinator = libraryCoordinatorFactory.create()
        addChild(libraryCoordinator)
        
        libraryCoordinator.start(at: mainTabBarView.libraryContainer)
    }
    
    public func runDictionaryFlow() {
        fatalError()
    }
}
