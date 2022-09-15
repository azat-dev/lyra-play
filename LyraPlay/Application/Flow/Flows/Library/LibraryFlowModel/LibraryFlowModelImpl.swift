//
//  LibraryFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation
import Combine

public final class LibraryFlowModelImpl: LibraryFlowModel {
    
    // MARK: - Properties
    
    private let viewModelFactory: MediaLibraryBrowserViewModelFactory
    private let libraryItemFlowModelFactory: LibraryItemFlowModelFactory
    private let importMediaFilesFlowModelFactory: ImportMediaFilesFlowModelFactory
    private let deleteMediaLibraryItemFlowModelFactory: DeleteMediaLibraryItemFlowModelFactory
    
    public lazy var listViewModel: MediaLibraryBrowserViewModel = {
        
        return viewModelFactory.create(delegate: self)
    } ()
    
    public var libraryItemFlow = CurrentValueSubject<LibraryItemFlowModel?, Never>(nil)
    public var importMediaFilesFlow = CurrentValueSubject<ImportMediaFilesFlowModel?, Never>(nil)
    public var deleteMediaLibraryItemFlow = CurrentValueSubject<DeleteMediaLibraryItemFlowModel?, Never>(nil)
    
    // MARK: - Initializers
    
    public init(
        viewModelFactory: MediaLibraryBrowserViewModelFactory,
        libraryItemFlowModelFactory: LibraryItemFlowModelFactory,
        importMediaFilesFlowModelFactory: ImportMediaFilesFlowModelFactory,
        deleteMediaLibraryItemFlowModelFactory: DeleteMediaLibraryItemFlowModelFactory
    ) {
        
        self.viewModelFactory = viewModelFactory
        self.libraryItemFlowModelFactory = libraryItemFlowModelFactory
        self.importMediaFilesFlowModelFactory = importMediaFilesFlowModelFactory
        self.deleteMediaLibraryItemFlowModelFactory = deleteMediaLibraryItemFlowModelFactory
    }
}

// MARK: - Input Methods

extension LibraryFlowModelImpl {
    
}

// MARK: - DeleteLibraryItem

extension LibraryFlowModelImpl: DeleteMediaLibraryItemFlowDelegate {
    
    private func reloadList() {
        
        Task {
            await self.listViewModel.load()
        }
    }
    
    public func deleteMediaLibraryItemFlowDidCancel() {
        
        deleteMediaLibraryItemFlow.value = nil
        reloadList()
    }
    
    public func deleteMediaLibraryItemFlowDidFinish() {
        
        deleteMediaLibraryItemFlow.value = nil
        reloadList()
    }
}

// MARK: - MediaLibraryBrowserViewModelDelegate

extension LibraryFlowModelImpl: MediaLibraryBrowserViewModelDelegate {
    
    public func runImportMediaFilesFlow() {
        
        let importFlow = importMediaFilesFlowModelFactory.create(delegate: self)
        self.importMediaFilesFlow.value = importFlow
    }
    
    public func runOpenLibraryItemFlow(mediaId: UUID) {
        
        guard libraryItemFlow.value == nil else {
            return
        }
        
        let itemFlow = libraryItemFlowModelFactory.create(for: mediaId, delegate: self)
        itemFlow.delegate = self
        
        libraryItemFlow.value = itemFlow
    }
    
    public func runDeleteLibraryItemFlow(mediaId: UUID) {
        
        guard deleteMediaLibraryItemFlow.value == nil else {
            return
        }
        
        let deleteMediaLibraryItemFlow = deleteMediaLibraryItemFlowModelFactory.create(itemId: mediaId, delegate: self)
        self.deleteMediaLibraryItemFlow.value = deleteMediaLibraryItemFlow
    }
}

// MARK: - LibraryItemFlowModelDelegate

extension LibraryFlowModelImpl: LibraryItemFlowModelDelegate {
    
    public func didFinishLibraryItemFlow() {
        
        libraryItemFlow.value = nil
    }
}

// MARK: - ImportMediaFilesFlowModelDelegate

extension LibraryFlowModelImpl: ImportMediaFilesFlowModelDelegate {
    
    public func importMediaFilesFlowDidFinish() {
        
        importMediaFilesFlow.value = nil
        
        Task {
            await self.listViewModel.load()
        }
    }
    
    public func importMediaFilesFlowProgress(totalFilesCount: Int, importedFilesCount: Int) {
        
        importMediaFilesFlow.value = nil
        
        Task {
            await self.listViewModel.load()
        }
    }
}
