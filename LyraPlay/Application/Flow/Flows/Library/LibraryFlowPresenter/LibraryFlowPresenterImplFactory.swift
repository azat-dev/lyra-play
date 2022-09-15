//
//  LibraryFlowPresenterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation

public final class LibraryFlowPresenterImplFactory: LibraryFlowPresenterFactory {
    
    private let listViewFactory: MediaLibraryBrowserViewFactory
    private let libraryItemFlowPresenterFactory: LibraryItemFlowPresenterFactory
    private let importMediaFilesFlowPresenterFactory: ImportMediaFilesFlowPresenterFactory
    private let deleteMediaLibraryItemFlowPresenterFactory: DeleteMediaLibraryItemFlowPresenterFactory
    
    public init(
        listViewFactory: MediaLibraryBrowserViewFactory,
        libraryItemFlowPresenterFactory: LibraryItemFlowPresenterFactory,
        importMediaFilesFlowPresenterFactory: ImportMediaFilesFlowPresenterFactory,
        deleteMediaLibraryItemFlowPresenterFactory: DeleteMediaLibraryItemFlowPresenterFactory
    ) {
        
        self.listViewFactory = listViewFactory
        self.libraryItemFlowPresenterFactory = libraryItemFlowPresenterFactory
        self.importMediaFilesFlowPresenterFactory = importMediaFilesFlowPresenterFactory
        self.deleteMediaLibraryItemFlowPresenterFactory = deleteMediaLibraryItemFlowPresenterFactory
    }
    
    public func create(for flowModel: LibraryFlowModel) -> LibraryFlowPresenter {
        
        return LibraryFlowPresenterImpl(
            flowModel: flowModel,
            listViewFactory: listViewFactory,
            libraryItemFlowPresenterFactory: libraryItemFlowPresenterFactory,
            importMediaFilesFlowPresenterFactory: importMediaFilesFlowPresenterFactory,
            deleteMediaLibraryItemFlowPresenterFactory: deleteMediaLibraryItemFlowPresenterFactory
        )
    }
}
