//
//  LibraryFolderFlowPresenterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation

public final class LibraryFolderFlowPresenterImplFactory: LibraryFolderFlowPresenterFactory {
    
    private let listViewFactory: MediaLibraryBrowserViewFactory
    private let libraryItemFlowPresenterFactory: LibraryFileFlowPresenterFactory
    private let addMediaLibraryItemFlowPresenterFactory: AddMediaLibraryItemFlowPresenterFactory
    private let deleteMediaLibraryItemFlowPresenterFactory: DeleteMediaLibraryItemFlowPresenterFactory
    
    public init(
        listViewFactory: MediaLibraryBrowserViewFactory,
        libraryItemFlowPresenterFactory: LibraryFileFlowPresenterFactory,
        addMediaLibraryItemFlowPresenterFactory: AddMediaLibraryItemFlowPresenterFactory,
        deleteMediaLibraryItemFlowPresenterFactory: DeleteMediaLibraryItemFlowPresenterFactory
    ) {
        
        self.listViewFactory = listViewFactory
        self.libraryItemFlowPresenterFactory = libraryItemFlowPresenterFactory
        self.addMediaLibraryItemFlowPresenterFactory = addMediaLibraryItemFlowPresenterFactory
        self.deleteMediaLibraryItemFlowPresenterFactory = deleteMediaLibraryItemFlowPresenterFactory
    }
    
    public func create(for flowModel: LibraryFolderFlowModel) -> LibraryFolderFlowPresenter {
        
        return LibraryFolderFlowPresenterImpl(
            flowModel: flowModel,
            listViewFactory: listViewFactory,
            libraryItemFlowPresenterFactory: libraryItemFlowPresenterFactory,
            addMediaLibraryItemFlowPresenterFactory: addMediaLibraryItemFlowPresenterFactory,
            deleteMediaLibraryItemFlowPresenterFactory: deleteMediaLibraryItemFlowPresenterFactory
        )
    }
}
