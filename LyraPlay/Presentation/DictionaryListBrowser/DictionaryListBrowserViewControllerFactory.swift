//
//  DictionaryListBrowserViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.08.22.
//

import Foundation

final class DictionaryListBrowserViewControllerFactory {
    
    private let coordinator: DictionaryListBrowserCoordinator
    private let browseDictionaryUseCase: BrowseDictionaryUseCase
    
    init(
        coordinator: DictionaryListBrowserCoordinator,
        browseDictionaryUseCase: BrowseDictionaryUseCase
    ) {
        
        self.coordinator = coordinator
        self.browseDictionaryUseCase = browseDictionaryUseCase
    }
    
    func build() -> DictionaryListBrowserViewController {
        
        let viewModel = DefaultDictionaryListBrowserViewModel(
            coordinator: coordinator,
            browseDictionaryUseCase: browseDictionaryUseCase
        )
        return DictionaryListBrowserViewController(viewModel: viewModel)
    }
}
