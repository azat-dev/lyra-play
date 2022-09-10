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
    
    public lazy var listViewModel: AudioFilesBrowserViewModel = {
        
        return viewModelFactory.create(delegate: self)
    } ()

    public var libraryItemFlow = CurrentValueSubject<LibraryItemFlowModel?, Never>(nil)
    
    // MARK: - Initializers

    public init(
        viewModelFactory: AudioFilesBrowserViewModelFactory,
        libraryItemFlowModelFactory: LibraryItemFlowModelFactory
    ) {

        self.viewModelFactory = viewModelFactory
        self.libraryItemFlowModelFactory = libraryItemFlowModelFactory
    }
}

// MARK: - Input Methods

extension LibraryFlowModelImpl {

}

// MARK: - AudioFilesBrowserViewModelDelegate

extension LibraryFlowModelImpl: AudioFilesBrowserViewModelDelegate {

    public func runImportMediaFilesFlow(completion: @escaping ([URL]?) -> Void) {
        
        fatalError()
    }
    
    public func runOpenLibraryItemFlow(mediaId: UUID) {
        
        guard libraryItemFlow.value == nil else {
            return
        }
        
        let itemFlow = libraryItemFlowModelFactory.create(for: mediaId)
        itemFlow.delegate = self
        
        libraryItemFlow.value = itemFlow
    }
}

extension LibraryFlowModelImpl: LibraryItemFlowModelDelegate {
    
    public func didFinishLibraryItemFlow() {
        
        libraryItemFlow.value = nil
    }
}
