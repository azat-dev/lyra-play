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
    
    private weak var delegate: DictionaryListBrowserViewModelDelegate?
    private let dictionaryListBrowserItemViewModelFactory: DictionaryListBrowserItemViewModelFactory
    
    private let browseDictionaryUseCase: BrowseDictionaryUseCase
    private let pronounceTextUseCaseFactory: PronounceTextUseCaseFactory
    
    public var isLoading = CurrentValueSubject<Bool, Never>(true)
    
    public var items = CurrentValueSubject<[UUID], Never>([])
    
    public var changedItems = PassthroughSubject<[UUID], Never>()
    
    private var playingItems = [UUID: (observer: AnyCancellable, pronounceUseCase: PronounceTextUseCase)]()
    private var itemsById = [UUID: DictionaryListBrowserItemViewModel]()
    
    // MARK: - Initializers
    
    public init(
        delegate: DictionaryListBrowserViewModelDelegate,
        dictionaryListBrowserItemViewModelFactory: DictionaryListBrowserItemViewModelFactory,
        browseDictionaryUseCase: BrowseDictionaryUseCase,
        pronounceTextUseCaseFactory: PronounceTextUseCaseFactory
    ) {
        
        self.delegate = delegate
        self.dictionaryListBrowserItemViewModelFactory = dictionaryListBrowserItemViewModelFactory
        self.browseDictionaryUseCase = browseDictionaryUseCase
        self.pronounceTextUseCaseFactory = pronounceTextUseCaseFactory
    }
}

// MARK: - DictionaryListBrowserItemViewModelDelegate

extension DictionaryListBrowserViewModelImpl: DictionaryListBrowserItemViewModelDelegate {
    
    private func updatePlayingItem(id: UUID) {

        DispatchQueue.main.async {
        
            guard var item = self.itemsById[id] else {
                return
            }
            
            let isPlaying = self.playingItems[id] != nil
            item.setIsPlaying(isPlaying)
            
            
            self.itemsById[id] = item
            self.changedItems.send([id])
        }
    }
    
    public func playSound(for itemId: UUID) {
        
        guard
            let item = itemsById[itemId],
            playingItems[itemId] == nil
        else {
            return
        }
        
        let pronounceUseCase = pronounceTextUseCaseFactory.create()
        
        let observer = pronounceUseCase.state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                
                guard let self = self else {
                    return
                }
                
                switch state {
                    
                case .loading, .playing:
                    break
                    
                case .finished:
                    
                    guard let playingItem = self.playingItems[itemId] else {
                        return
                    }
                    
                    playingItem.observer.cancel()
                    self.playingItems.removeValue(forKey: itemId)
                    self.updatePlayingItem(id: itemId)
                    break
                }
            }
        
        let _ = pronounceUseCase.pronounce(text: item.title, language: "en_US")
        playingItems[itemId] = (
            observer: observer,
            pronounceUseCase: pronounceUseCase
        )
        
        updatePlayingItem(id: itemId)
    }
    
    public func dictionaryListBrowserItemViewModelDidPlay(itemId: UUID) {
        
        playSound(for: itemId)
    }
}

// MARK: - Input Methods

extension DictionaryListBrowserViewModelImpl {
    
    public func load() async {
        
        if !isLoading.value {
            isLoading.value = true
        }
        
        let result = await browseDictionaryUseCase.listItems()
        
        guard case .success(let loadedItems) = result else {
            // TODO: Show error message
            return
        }
        
        DispatchQueue.main.async {
            
            self.itemsById.removeAll()
            
            var ids = [UUID]()
            
            loadedItems.forEach { item in
                
                let itemId = item.id
                
                ids.append(itemId)
                self.itemsById[itemId] = self.dictionaryListBrowserItemViewModelFactory.create(
                    for: item,
                    isPlaying: self.playingItems[itemId] != nil,
                    delegate: self
                )
            }
            
            self.items.value = ids
            self.isLoading.value = false
        }
    }
    
    public func addNewItem() {
        
        delegate?.runCreationFlow()
    }
    
    public func deleteItem(_ itemId: UUID) {
        
        delegate?.runDeleteDictionaryItemFlow(itemId: itemId)
    }
}

// MARK: - Output Methods

extension DictionaryListBrowserViewModelImpl {
    
    public func getItem(with id: UUID) -> DictionaryListBrowserItemViewModel {
        
        return itemsById[id]!
    }
}
