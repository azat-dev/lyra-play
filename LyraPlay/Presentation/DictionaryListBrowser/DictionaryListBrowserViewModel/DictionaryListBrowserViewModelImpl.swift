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
    
    private var delegate: DictionaryListBrowserViewModelDelegate
    private let browseDictionaryUseCase: BrowseDictionaryUseCase
    
    public var isLoading = CurrentValueSubject<Bool, Never>(true)
    public var listChanged: PassthroughSubject<DictionaryListBrowserChangeEvent, Never> = .init()
    
    // MARK: - Initializers
    
    public init(
        delegate: DictionaryListBrowserViewModelDelegate,
        browseDictionaryUseCase: BrowseDictionaryUseCase
    ) {
        
        self.delegate = delegate
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

        delegate.runCreationFlow()
    }
}

// MARK: - Output Methods

extension DictionaryListBrowserViewModelImpl {
    
}
