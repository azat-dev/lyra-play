//
//  MediaLibraryBrowserViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation
import Combine
import UIKit

public final class MediaLibraryBrowserViewModelImpl: MediaLibraryBrowserViewModel {
    
    // MARK: - Properties
    
    private let folderId: UUID?
    private weak var delegate: MediaLibraryBrowserViewModelDelegate?
    
    private let browseUseCase: BrowseMediaLibraryUseCase
    private let importFileUseCase: ImportAudioFileUseCase
    
    public var isLoading = Observable<Bool>(true)
    
    private var stubItemImage = UIImage(named: "Image.CoverPlaceholder")!
    
    private var itemsById = [UUID: MediaLibraryBrowserCellViewModel]()
    
    public var items = CurrentValueSubject<[UUID], Never>([])
    
    public var changedItems = PassthroughSubject<[UUID], Never>()
    
    
    // MARK: - Initializers
    
    public init(
        folderId: UUID?,
        delegate: MediaLibraryBrowserViewModelDelegate,
        browseUseCase: BrowseMediaLibraryUseCase,
        importFileUseCase: ImportAudioFileUseCase
    ) {
        
        self.delegate = delegate
        self.browseUseCase = browseUseCase
        self.importFileUseCase = importFileUseCase
        
        self.isLoading = Observable(true)
        self.folderId = folderId
    }
}

// MARK: - Input Methods

extension MediaLibraryBrowserViewModelImpl: MediaLibraryBrowserCellViewModelDelegate {
    
    public func mediaLibraryBrowserCellViewModelDidOpen(itemId: UUID) {
        
        delegate?.runOpenLibraryItemFlow(mediaId: itemId)
    }
}

extension MediaLibraryBrowserViewModelImpl {
    
    private func loadImages(names: [String]) async -> [String: UIImage] {
        
        var images = [String: UIImage]()
        
        for imageName in names {
            
            let result = await browseUseCase.fetchImage(name: imageName)
            guard case .success(let imageData) = result else {
                continue
            }
            
            images[imageName] = UIImage(data: imageData)
        }
        
        return images
    }
    
    public func load() async -> Void {
        
        isLoading.value = true
        
        let result = await browseUseCase.listItems(folderId: folderId)
        
        guard case .success(let loadedItems) = result else {
            return
        }
        
        let images = await loadImages(
            names: loadedItems.map { item in
                
                switch item {
                    
                case .folder(let item):
                    return item.image
                    
                case .file(let item):
                    return item.image
                }
            }.compactMap { $0 }
        )
        
        var newItems = [UUID: MediaLibraryBrowserCellViewModel]()
        var ids = [UUID]()
        
        loadedItems.forEach { item in
            
            let cellViewModel: MediaLibraryBrowserCellViewModel
            
            switch item {
                
            case .folder(let item):
                cellViewModel = MediaLibraryBrowserCellViewModel(
                    id: item.id,
                    isFolder: true,
                    title: item.title,
                    description: "",
                    image: images[item.image ?? ""] ?? stubItemImage,
                    delegate: self
                )
                
            case .file(let item):
                cellViewModel = MediaLibraryBrowserCellViewModel(
                    id: item.id,
                    isFolder: false,
                    title: item.title,
                    description: item.subtitle ?? "Unknown",
                    image: images[item.image ?? ""] ?? stubItemImage,
                    delegate: self
                )
            }
            
            newItems[cellViewModel.id] = cellViewModel
            ids.append(cellViewModel.id)
        }
        
        
        DispatchQueue.main.async { [weak self, newItems, ids] in
            
            guard let self = self else {
                return
            }
            
            self.itemsById = newItems
            self.items.value = ids
            self.isLoading.value = false
        }
    }
    
    public func addNewItem() -> Void {
        
        delegate?.runImportMediaFilesFlow(folderId: folderId)
    }
    
    public func deleteItem(_ id: UUID) {
        
        delegate?.runDeleteLibraryItemFlow(mediaId: id)
    }
}

// MARK: - Output Methods

extension MediaLibraryBrowserViewModelImpl {
    
    public func getItem(id: UUID) -> MediaLibraryBrowserCellViewModel {
        
        return itemsById[id]!
    }
}
