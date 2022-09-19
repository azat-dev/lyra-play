//
//  LibraryFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation

public final class LibraryFlowModelImplFactory: LibraryFlowModelFactory {

    // MARK: - Properties

    private let viewModelFactory: MediaLibraryBrowserViewModelFactory
    private let libraryItemFlowModelFactory: LibraryItemFlowModelFactory
    private let addMediaLibraryItemFlowModelFactory: AddMediaLibraryItemFlowModelFactory
    private let deleteMediaLibraryItemFlowModelFactory: DeleteMediaLibraryItemFlowModelFactory
    
    // MARK: - Initializers

    public init(
        viewModelFactory: MediaLibraryBrowserViewModelFactory,
        libraryItemFlowModelFactory: LibraryItemFlowModelFactory,
        addMediaLibraryItemFlowModelFactory: AddMediaLibraryItemFlowModelFactory,
        deleteMediaLibraryItemFlowModelFactory: DeleteMediaLibraryItemFlowModelFactory
    ) {

        self.viewModelFactory = viewModelFactory
        self.libraryItemFlowModelFactory = libraryItemFlowModelFactory
        self.addMediaLibraryItemFlowModelFactory = addMediaLibraryItemFlowModelFactory
        self.deleteMediaLibraryItemFlowModelFactory = deleteMediaLibraryItemFlowModelFactory
    }

    // MARK: - Methods

    public func create(folderId: UUID?) -> LibraryFlowModel {

        return LibraryFlowModelImpl(
            folderId: folderId,
            viewModelFactory: viewModelFactory,
            libraryItemFlowModelFactory: libraryItemFlowModelFactory,
            addMediaLibraryItemFlowModelFactory: addMediaLibraryItemFlowModelFactory,
            deleteMediaLibraryItemFlowModelFactory: deleteMediaLibraryItemFlowModelFactory
        )
    }
}
