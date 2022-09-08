//
//  LibraryFlowPresenterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation

public final class LibraryFlowPresenterImpl: LibraryFlowPresenter {

    // MARK: - Properties
    
    private let flowModel: LibraryFlowModel
    
    private let listViewFactory: AudioFilesBrowserViewFactory

    // MARK: - Initializers
    
    public init(flowModel: LibraryFlowModel, listViewFactory: AudioFilesBrowserViewFactory) {
        
        self.flowModel = flowModel
        self.listViewFactory = listViewFactory
    }
}

// MARK: - Methods

extension LibraryFlowPresenterImpl {

    public func present(at container: StackPresentationContainer) {
        
        let view = listViewFactory.create(viewModel: flowModel.listViewModel)
        container.setRoot(view)
    }
}
