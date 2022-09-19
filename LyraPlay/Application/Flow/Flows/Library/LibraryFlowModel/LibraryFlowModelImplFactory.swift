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
    private let importMediaFilesFlowModelFactory: ImportMediaFilesFlowModelFactory
    private let deleteMediaLibraryItemFlowModelFactory: DeleteMediaLibraryItemFlowModelFactory
    
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

    // MARK: - Methods

    public func create(folderId: UUID?) -> LibraryFlowModel {

        return LibraryFlowModelImpl(
            folderId: folderId,
            viewModelFactory: viewModelFactory,
            libraryItemFlowModelFactory: libraryItemFlowModelFactory,
            importMediaFilesFlowModelFactory: importMediaFilesFlowModelFactory,
            deleteMediaLibraryItemFlowModelFactory: deleteMediaLibraryItemFlowModelFactory
        )
    }
}
