//
//  LibraryFlowPresenterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation

public final class LibraryFlowPresenterImplFactory: LibraryFlowPresenterFactory {
    
    private let listViewFactory: AudioFilesBrowserViewFactory
    private let libraryItemFlowPresenterFactory: LibraryItemFlowPresenterFactory
    private let importMediaFilesFlowPresenterFactory: ImportMediaFilesFlowPresenterFactory
    
    public init(
        listViewFactory: AudioFilesBrowserViewFactory,
        libraryItemFlowPresenterFactory: LibraryItemFlowPresenterFactory,
        importMediaFilesFlowPresenterFactory: ImportMediaFilesFlowPresenterFactory
    ) {
        
        self.listViewFactory = listViewFactory
        self.libraryItemFlowPresenterFactory = libraryItemFlowPresenterFactory
        self.importMediaFilesFlowPresenterFactory = importMediaFilesFlowPresenterFactory
    }
    
    public func create(for flowModel: LibraryFlowModel) -> LibraryFlowPresenter {
        
        return LibraryFlowPresenterImpl(
            flowModel: flowModel,
            listViewFactory: listViewFactory,
            libraryItemFlowPresenterFactory: libraryItemFlowPresenterFactory,
            importMediaFilesFlowPresenterFactory: importMediaFilesFlowPresenterFactory
        )
    }
}
