//
//  MediaLibraryBrowserViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public protocol MediaLibraryBrowserViewModelDelegate: AnyObject {
    
    func runImportMediaFilesFlow()
    
    func runOpenLibraryItemFlow(mediaId: UUID)
}

public protocol MediaLibraryBrowserUpdateDelegate: AnyObject {
    
    func filesDidUpdate(updatedFiles: [MediaLibraryBrowserCellViewModel])
}

public protocol MediaLibraryBrowserViewModelInput: AnyObject {
    
    func load() async -> Void
    
    func addNewItem() -> Void
}

public protocol MediaLibraryBrowserViewModelOutput: AnyObject {
    
    var isLoading: Observable<Bool> { get }
    
    var filesDelegate: MediaLibraryBrowserUpdateDelegate? { get set }
}

public protocol MediaLibraryBrowserViewModel: MediaLibraryBrowserViewModelOutput, MediaLibraryBrowserViewModelInput {}
