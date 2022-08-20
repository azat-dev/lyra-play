//
//  DictionaryListBrowserViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.08.2022.
//

import Foundation
import Combine

// MARK: - Interfaces

public protocol DictionaryListBrowserCoordinator {
    
    func addNewDictionaryItem(completion: @escaping (DictionaryItem) -> Void)
}

public enum DictionaryListBrowserChangeEvent: Equatable {
    
    case loaded(items: [DictionaryListBrowserItemViewModel])
}

public struct DictionaryListBrowserItemViewModel: Equatable, Hashable {
    
    public var id: UUID
    public var title: String
    public var description: String
    
    public init(
        id: UUID,
        title: String,
        description: String
    ) {
        
        self.id = id
        self.title = title
        self.description = description
    }
}

public protocol DictionaryListBrowserViewModelInput {
    
    func load() async
    
    func addNewItem()
}


public protocol DictionaryListBrowserViewModelOutput {
    
    var isLoading: CurrentValueSubject<Bool, Never> { get }
    
    var listChanged: PassthroughSubject<DictionaryListBrowserChangeEvent, Never> { get }
}

public protocol DictionaryListBrowserViewModel: DictionaryListBrowserViewModelOutput, DictionaryListBrowserViewModelInput {
}

// MARK: - Implementations

public final class DefaultDictionaryListBrowserViewModel: DictionaryListBrowserViewModel {
    
    // MARK: - Properties
    
    private let coordinator: DictionaryListBrowserCoordinator
    private let browseDictionaryUseCase: BrowseDictionaryUseCase
    
    public let isLoading = CurrentValueSubject<Bool, Never>(true)
    public let listChanged: PassthroughSubject<DictionaryListBrowserChangeEvent, Never> = .init()
    
    // MARK: - Initializers
    
    public init(
        coordinator: DictionaryListBrowserCoordinator,
        browseDictionaryUseCase: BrowseDictionaryUseCase
    ) {
        
        self.coordinator = coordinator
        self.browseDictionaryUseCase = browseDictionaryUseCase
    }
}

// MARK: - Input Methods

extension DefaultDictionaryListBrowserViewModel {
    
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

        coordinator.addNewDictionaryItem { _ in
            Task {
                await self.load()
            }
        }
    }
}
