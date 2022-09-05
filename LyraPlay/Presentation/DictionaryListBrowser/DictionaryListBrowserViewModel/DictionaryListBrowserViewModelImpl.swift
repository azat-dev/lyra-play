//
//  DictionaryListBrowserViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

import Foundation
import Combine

public final class DictionaryListBrowserViewModelImpl: DictionaryListBrowserViewModel {

    // MARK: - Properties

    private weak var coordinator: DictionaryCoordinatorInput?
    private let browseDictionaryUseCase: BrowseDictionaryUseCase
    
    public var isLoading = CurrentValueSubject<Bool, Never>(true)
    public var listChanged: PassthroughSubject<DictionaryListBrowserChangeEvent, Never> = .init()

    // MARK: - Initializers

    public init(
        coordinator: DictionaryCoordinatorInput,
        browseDictionaryUseCase: BrowseDictionaryUseCase
    ) {

        self.coordinator = coordinator
        self.browseDictionaryUseCase = browseDictionaryUseCase
    }
}

// MARK: - Input Methods

extension DictionaryListBrowserViewModelImpl {

    private func map(_ item: BrowseListDictionaryItem) -> DictionaryListBrowserItemViewModel {
        
        return .init(
            id: item.id,
            title: item.originalText,
            description: item.translatedText
        )
    }
    
    public func load() async {
        
        if !isLoading.value {
            isLoading.value = true
        }
        
        let result = await browseDictionaryUseCase.listItems()
        
        guard case .success(let loadedItems) = result else {
            // TODO: Show error message
            return
        }
        
        listChanged.send(.loaded(items: loadedItems.map(self.map)))
        isLoading.value = false
    }
    
    public func addNewItem() {

        coordinator?.runCreationFlow { _ in
            Task {
                await self.load()
            }
        }
    }
}

// MARK: - Output Methods

extension DictionaryListBrowserViewModelImpl {

}
