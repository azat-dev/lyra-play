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
    
    private let viewModelFactory: AudioFilesBrowserViewModelFactory
    private let libraryItemFlowModelFactory: LibraryItemFlowModelFactory
    private let importMediaFilesFlowModelFactory: ImportMediaFilesFlowModelFactory
    
    public lazy var listViewModel: AudioFilesBrowserViewModel = {
        
        return viewModelFactory.create(delegate: self)
    } ()
    
    public var libraryItemFlow = CurrentValueSubject<LibraryItemFlowModel?, Never>(nil)
    public var importMediaFilesFlow = CurrentValueSubject<ImportMediaFilesFlowModel?, Never>(nil)
    
    // MARK: - Initializers
    
    public init(
        viewModelFactory: AudioFilesBrowserViewModelFactory,
        libraryItemFlowModelFactory: LibraryItemFlowModelFactory,
        importMediaFilesFlowModelFactory: ImportMediaFilesFlowModelFactory
    ) {
        
        self.viewModelFactory = viewModelFactory
        self.libraryItemFlowModelFactory = libraryItemFlowModelFactory
        self.importMediaFilesFlowModelFactory = importMediaFilesFlowModelFactory
    }
}

// MARK: - Input Methods

extension LibraryFlowModelImpl {
    
}

// MARK: - AudioFilesBrowserViewModelDelegate

extension LibraryFlowModelImpl: AudioFilesBrowserViewModelDelegate {
    
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
