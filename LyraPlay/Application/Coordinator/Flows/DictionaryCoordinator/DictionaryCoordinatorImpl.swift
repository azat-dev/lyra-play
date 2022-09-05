//
//  DictionaryCoordinatorImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

import Foundation

public final class DictionaryCoordinatorImpl: BaseCoordinator, DictionaryCoordinator {

    // MARK: - Properties

    private let viewModelFactory: DictionaryListBrowserViewModelFactory
    private let viewFactory: DictionaryListBrowserViewFactory

    // MARK: - Initializers

    public init(
        viewModelFactory: DictionaryListBrowserViewModelFactory,
        viewFactory: DictionaryListBrowserViewFactory
    ) {

        self.viewModelFactory = viewModelFactory
        self.viewFactory = viewFactory
    }
    
    public func start(at container: StackPresentationContainer) {
        
        let viewModel = viewModelFactory.create(coordinator: self)
        let view = viewFactory.create(viewModel: viewModel)
        
        container.push(view)
    }
}

// MARK: - Input Methods

extension DictionaryCoordinatorImpl {

    public func runCreationFlow(completion: (DictionaryItem?) -> Void) {
    }
}
