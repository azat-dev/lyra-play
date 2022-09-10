//
//  LibraryItemFlowPresenterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.09.22.
//

import Foundation

public final class LibraryItemFlowPresenterImplFactory: LibraryItemFlowPresenterFactory {
    
    // MARK: - Properties
    
    private let libraryItemViewFactory: LibraryItemViewFactory
    private let attachSubtitlesFlowPresenterFactory: AttachSubtitlesFlowPresenterFactory
    
    // MARK: - Initializers
    
    public init(
        libraryItemViewFactory: LibraryItemViewFactory,
        attachSubtitlesFlowPresenterFactory: AttachSubtitlesFlowPresenterFactory
    ) {
        
        self.libraryItemViewFactory = libraryItemViewFactory
        self.attachSubtitlesFlowPresenterFactory = attachSubtitlesFlowPresenterFactory
    }
    
    // MARK: - Methods
    
    public func create(for flowModel: LibraryItemFlowModel) -> LibraryItemFlowPresenter {
        
        return LibraryItemFlowPresenterImpl(
            flowModel: flowModel,
            libraryItemViewFactory: libraryItemViewFactory,
            attachSubtitlesFlowPresenterFactory: attachSubtitlesFlowPresenterFactory
        )
    }
}
