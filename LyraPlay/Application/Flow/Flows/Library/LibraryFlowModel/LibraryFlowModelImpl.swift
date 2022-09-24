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
    
    public let folderId: UUID?
    
    private let viewModelFactory: MediaLibraryBrowserViewModelFactory
    private let libraryFileFlowModelFactory: LibraryFileFlowModelFactory
    private let addMediaLibraryItemFlowModelFactory: AddMediaLibraryItemFlowModelFactory
    private let deleteMediaLibraryItemFlowModelFactory: DeleteMediaLibraryItemFlowModelFactory
    
    public lazy var listViewModel: MediaLibraryBrowserViewModel = {
        
        return viewModelFactory.create(folderId: folderId, delegate: self)
    } ()
    
    public var libraryFileFlow = CurrentValueSubject<LibraryFileFlowModel?, Never>(nil)
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

extension LibraryFlowModelImpl {}

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
    
    public func deleteMediaLibraryItemFlowDidDispose() {
        
        deleteMediaLibraryItemFlow.value = nil
        reloadList()
    }
}

// MARK: - MediaLibraryBrowserViewModelDelegate

extension LibraryFlowModelImpl: MediaLibraryBrowserViewModelDelegate {
    
    public func runAddMediaLibratyItemFlow(folderId: UUID?) {
        
        let addMediaLibraryItemFlow = addMediaLibraryItemFlowModelFactory.create(
            targetFolderId: folderId,
            delegate: self
        )
        self.addMediaLibraryItemFlow.value = addMediaLibraryItemFlow
    }
    
    public func runOpenLibraryItemFlow(mediaId: UUID) {
        
        guard libraryFileFlow.value == nil else {
            return
        }
        
        let itemFlow = libraryFileFlowModelFactory.create(for: mediaId, delegate: self)
        itemFlow.delegate = self
        
        libraryFileFlow.value = itemFlow
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

extension LibraryFlowModelImpl: LibraryFileFlowModelDelegate {
    
    public func libraryFileFlowDidDispose() {
        
        libraryFileFlow.value = nil
    }
}

// MARK: - ImportMediaFilesFlowModelDelegate

extension LibraryFlowModelImpl: AddMediaLibraryItemFlowModelDelegate {
    
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
