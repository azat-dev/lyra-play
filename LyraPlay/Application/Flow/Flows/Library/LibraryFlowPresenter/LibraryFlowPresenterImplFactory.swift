//
//  LibraryFlowPresenterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation

public final class LibraryFlowPresenterImplFactory: LibraryFlowPresenterFactory {
    
    private let listViewFactory: MediaLibraryBrowserViewFactory
    private let libraryItemFlowPresenterFactory: LibraryFolderFlowPresenterFactory
    private let addMediaLibraryItemFlowPresenterFactory: AddMediaLibraryItemFlowPresenterFactory
    private let deleteMediaLibraryItemFlowPresenterFactory: DeleteMediaLibraryItemFlowPresenterFactory
    
    public init(
        listViewFactory: MediaLibraryBrowserViewFactory,
        libraryItemFlowPresenterFactory: LibraryFolderFlowPresenterFactory,
        addMediaLibraryItemFlowPresenterFactory: AddMediaLibraryItemFlowPresenterFactory,
        deleteMediaLibraryItemFlowPresenterFactory: DeleteMediaLibraryItemFlowPresenterFactory
    ) {
        
        self.listViewFactory = listViewFactory
        self.libraryItemFlowPresenterFactory = libraryItemFlowPresenterFactory
        self.addMediaLibraryItemFlowPresenterFactory = addMediaLibraryItemFlowPresenterFactory
        self.deleteMediaLibraryItemFlowPresenterFactory = deleteMediaLibraryItemFlowPresenterFactory
    }
    
    public func create(for flowModel: LibraryFlowModel) -> LibraryFlowPresenter {
        
        return LibraryFlowPresenterImpl(
            flowModel: flowModel,
            listViewFactory: listViewFactory,
            libraryItemFlowPresenterFactory: libraryItemFlowPresenterFactory,
            addMediaLibraryItemFlowPresenterFactory: addMediaLibraryItemFlowPresenterFactory,
            deleteMediaLibraryItemFlowPresenterFactory: deleteMediaLibraryItemFlowPresenterFactory
        )
    }
}
