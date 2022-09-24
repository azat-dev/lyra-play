//
//  LibraryFolderFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation
import Combine

public final class LibraryFolderFlowModelImpl: LibraryFolderFlowModel {
    
    // MARK: - Properties
    
    public let folderId: UUID?
    
    private let viewModelFactory: MediaLibraryBrowserViewModelFactory
    private let libraryFileFlowModelFactory: LibraryFileFlowModelFactory
    private let addMediaLibraryItemFlowModelFactory: AddMediaLibraryItemFlowModelFactory
    private let deleteMediaLibraryItemFlowModelFactory: DeleteMediaLibraryItemFlowModelFactory
    
    public lazy var listViewModel: MediaLibraryBrowserViewModel = {
        
        return viewModelFactory.create(folderId: folderId, delegate: self)
    } ()
    
    public var libraryItemFlow = CurrentValueSubject<LibraryItemFlowModel?, Never>(nil)
    public var addMediaLibraryItemFlow = CurrentValueSubject<AddMediaLibraryItemFlowModel?, Never>(nil)
    public var deleteMediaLibraryItemFlow = CurrentValueSubject<DeleteMediaLibraryItemFlowModel?, Never>(nil)
    
    // MARK: - Initializers
    
    public init(
        folderId: UUID?,
        viewModelFactory: MediaLibraryBrowserViewModelFactory,
        libraryFileFlowModelFactory: LibraryFileFlowModelFactory,
        addMediaLibraryItemFlowModelFactory: AddMediaLibraryItemFlowModelFactory,
        deleteMediaLibraryItemFlowModelFactory: DeleteMediaLibraryItemFlowModelFactory
    ) {
        
        self.folderId = folderId
        self.viewModelFactory = viewModelFactory
        self.libraryFileFlowModelFactory = libraryFileFlowModelFactory
        self.addMediaLibraryItemFlowModelFactory = addMediaLibraryItemFlowModelFactory
        self.deleteMediaLibraryItemFlowModelFactory = deleteMediaLibraryItemFlowModelFactory
    }
}

// MARK: - Input Methods

extension LibraryFolderFlowModelImpl {}

// MARK: - DeleteLibraryItem

extension LibraryFolderFlowModelImpl: DeleteMediaLibraryItemFlowDelegate {
    
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
    
    public func deleteMediaLibraryItemFlowDidDispose() {
        
        deleteMediaLibraryItemFlow.value = nil
        reloadList()
    }
}

// MARK: - MediaLibraryBrowserViewModelDelegate

extension LibraryFolderFlowModelImpl: MediaLibraryBrowserViewModelDelegate {
    
    public func runAddMediaLibratyItemFlow(folderId: UUID?) {
        
        let addMediaLibraryItemFlow = addMediaLibraryItemFlowModelFactory.create(
            targetFolderId: folderId,
            delegate: self
        )
        self.addMediaLibraryItemFlow.value = addMediaLibraryItemFlow
    }
    
    public func runOpenLibraryItemFlow(itemId: UUID) {
        
        guard libraryItemFlow.value == nil else {
            return
        }
        
        let itemFlow = libraryFileFlowModelFactory.create(for: itemId, delegate: self)
        
        libraryItemFlow.value = .file(itemFlow)
    }
    
    public func runDeleteLibraryItemFlow(mediaId: UUID) {
        
        guard deleteMediaLibraryItemFlow.value == nil else {
            return
        }
        
        let deleteMediaLibraryItemFlow = deleteMediaLibraryItemFlowModelFactory.create(itemId: mediaId, delegate: self)
        self.deleteMediaLibraryItemFlow.value = deleteMediaLibraryItemFlow
    }
}

// MARK: - LibraryFileFlowModelDelegate

extension LibraryFolderFlowModelImpl: LibraryFileFlowModelDelegate {
    
    public func libraryFileFlowDidDispose() {
        
        libraryItemFlow.value = nil
    }
}

// MARK: - ImportMediaFilesFlowModelDelegate

extension LibraryFolderFlowModelImpl: AddMediaLibraryItemFlowModelDelegate {
    
    public func addMediaLibraryItemFlowModelDidFinish() {
        
        reloadList()
        addMediaLibraryItemFlow.value = nil
    }
    
    public func addMediaLibraryItemFlowModelDidDispose() {
        
        addMediaLibraryItemFlow.value = nil
    }
    
    public func addMediaLibraryItemFlowModelDidCancel() {

        reloadList()
        addMediaLibraryItemFlow.value = nil
    }
}
