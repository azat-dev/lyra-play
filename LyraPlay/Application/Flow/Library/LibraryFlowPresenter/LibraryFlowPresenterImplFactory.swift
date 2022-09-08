//
//  LibraryFlowPresenterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation

public final class LibraryFlowPresenterImplFactory: LibraryFlowPresenterFactory {
    
    private let listViewFactory: AudioFilesBrowserViewFactory
    
    public init(listViewFactory: AudioFilesBrowserViewFactory) {
        
        self.listViewFactory = listViewFactory
    }
    
    public func create(for flowModel: LibraryFlowModel) -> LibraryFlowPresenter {
        
        return LibraryFlowPresenterImpl(
            flowModel: flowModel,
            listViewFactory: listViewFactory
        )
    }
}
