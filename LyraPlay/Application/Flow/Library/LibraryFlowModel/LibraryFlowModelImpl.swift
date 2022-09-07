//
//  LibraryFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation

public final class LibraryFlowModelImpl: LibraryFlowModel, LibraryCoordinatorInput {

    // MARK: - Properties

    private let viewModelFactory: AudioFilesBrowserViewModelFactory
    
    public lazy var listViewModel: AudioFilesBrowserViewModel = {
        
        return viewModelFactory.create(delegate: self)
    } ()

    // MARK: - Initializers

    public init(viewModelFactory: AudioFilesBrowserViewModelFactory) {

        self.viewModelFactory = viewModelFactory
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
        
        fatalError()
    }
}
