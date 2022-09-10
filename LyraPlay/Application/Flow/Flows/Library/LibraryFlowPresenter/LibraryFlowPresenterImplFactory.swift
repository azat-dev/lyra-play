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
    
    public init(
        listViewFactory: AudioFilesBrowserViewFactory,
        libraryItemFlowPresenterFactory: LibraryItemFlowPresenterFactory
    ) {
        
        self.listViewFactory = listViewFactory
        self.libraryItemFlowPresenterFactory = libraryItemFlowPresenterFactory
    }
    
    public func create(for flowModel: LibraryFlowModel) -> LibraryFlowPresenter {
        
        return LibraryFlowPresenterImpl(
            flowModel: flowModel,
            listViewFactory: listViewFactory,
            libraryItemFlowPresenterFactory: libraryItemFlowPresenterFactory
        )
    }
}
