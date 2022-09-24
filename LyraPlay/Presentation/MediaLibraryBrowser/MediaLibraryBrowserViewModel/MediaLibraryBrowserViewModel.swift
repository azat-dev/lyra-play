//
//  MediaLibraryBrowserViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation
import Combine

public protocol MediaLibraryBrowserViewModelDelegate: AnyObject {
    
    func runAddMediaLibratyItemFlow(folderId: UUID?)
    
    func runOpenLibraryItemFlow(itemId: UUID)
    
    func runDeleteLibraryItemFlow(mediaId: UUID)
}

public protocol MediaLibraryBrowserViewModelInput: AnyObject {
    
    func load() async -> Void
    
    func addNewItem() -> Void
    
    func deleteItem(_ id: UUID) -> Void
}

public protocol MediaLibraryBrowserViewModelOutput: AnyObject {
    
    var isLoading: Observable<Bool> { get }
    
    var items: CurrentValueSubject<[UUID], Never> { get }
    
    var changedItems: PassthroughSubject<[UUID], Never> { get }
    
    func getItem(id: UUID) -> MediaLibraryBrowserCellViewModel
}

public protocol MediaLibraryBrowserViewModel: MediaLibraryBrowserViewModelOutput, MediaLibraryBrowserViewModelInput {}
