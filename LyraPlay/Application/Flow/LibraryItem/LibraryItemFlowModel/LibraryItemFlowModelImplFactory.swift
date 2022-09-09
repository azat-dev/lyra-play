//
//  LibraryItemFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.09.22.
//

import Foundation

public final class LibraryItemFlowModelImplFactory: LibraryItemFlowModelFactory {

    // MARK: - Properties
    
    private let libraryItemViewModelFactory: LibraryItemViewModelFactory

    // MARK: - Initializers
    
    public init(libraryItemViewModelFactory: LibraryItemViewModelFactory) {
        
        self.libraryItemViewModelFactory = libraryItemViewModelFactory
    }
    
    // MARK: - Methods
    
    public func create(for mediaId: UUID) -> LibraryItemFlowModel {

        return LibraryItemFlowModelImpl(
            mediaId: mediaId,
            viewModelFactory: libraryItemViewModelFactory
        )
    }
}
