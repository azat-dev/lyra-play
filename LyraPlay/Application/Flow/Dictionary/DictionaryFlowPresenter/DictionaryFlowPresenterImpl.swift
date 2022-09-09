//
//  DictionaryFlowPresenterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation

public final class DictionaryFlowPresenterImpl: DictionaryFlowPresenter {

    // MARK: - Properties
    
    private let flowModel: DictionaryFlowModel
    
    private let listViewFactory: DictionaryListBrowserViewFactory

    // MARK: - Initializers
    
    public init(flowModel: DictionaryFlowModel, listViewFactory: DictionaryListBrowserViewFactory) {
        
        self.flowModel = flowModel
        self.listViewFactory = listViewFactory
    }
}

// MARK: - Methods

extension DictionaryFlowPresenterImpl {

    public func present(at container: StackPresentationContainer) {
        
        let view = listViewFactory.create(viewModel: flowModel.listViewModel)
        container.setRoot(view)
    }
}