//
//  LibraryFolderFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation

public final class LibraryFolderFlowModelImplFactory: LibraryFolderFlowModelFactory {

    // MARK: - Properties

    private let viewModelFactory: MediaLibraryBrowserViewModelFactory
    private let libraryFileFlowModelFactory: LibraryFileFlowModelFactory
    private let addMediaLibraryItemFlowModelFactory: AddMediaLibraryItemFlowModelFactory
    private let deleteMediaLibraryItemFlowModelFactory: DeleteMediaLibraryItemFlowModelFactory
    
    // MARK: - Initializers

    public init(
        viewModelFactory: MediaLibraryBrowserViewModelFactory,
        libraryFileFlowModelFactory: LibraryFileFlowModelFactory,
        addMediaLibraryItemFlowModelFactory: AddMediaLibraryItemFlowModelFactory,
        deleteMediaLibraryItemFlowModelFactory: DeleteMediaLibraryItemFlowModelFactory
    ) {

        self.viewModelFactory = viewModelFactory
        self.libraryFileFlowModelFactory = libraryFileFlowModelFactory
        self.addMediaLibraryItemFlowModelFactory = addMediaLibraryItemFlowModelFactory
        self.deleteMediaLibraryItemFlowModelFactory = deleteMediaLibraryItemFlowModelFactory
    }

    // MARK: - Methods

    public func make(folderId: UUID?) -> LibraryFolderFlowModel {

        return LibraryFolderFlowModelImpl(
            folderId: folderId,
            viewModelFactory: viewModelFactory,
            libraryFileFlowModelFactory: libraryFileFlowModelFactory,
            addMediaLibraryItemFlowModelFactory: addMediaLibraryItemFlowModelFactory,
            deleteMediaLibraryItemFlowModelFactory: deleteMediaLibraryItemFlowModelFactory
        )
    }
}
