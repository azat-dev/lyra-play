//
//  DictionaryFlowPresenterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation

public final class DictionaryFlowPresenterImplFactory: DictionaryFlowPresenterFactory {
    
    // MARK: - Properties
    
    private let listViewFactory: DictionaryListBrowserViewFactory
    private let addDictionaryItemFlowPresenterFactory: AddDictionaryItemFlowPresenterFactory
    
    // MARK: - Initializers
    
    public init(
        listViewFactory: DictionaryListBrowserViewFactory,
        addDictionaryItemFlowPresenterFactory: AddDictionaryItemFlowPresenterFactory
    ) {
        
        self.listViewFactory = listViewFactory
        self.addDictionaryItemFlowPresenterFactory = addDictionaryItemFlowPresenterFactory
    }
    
    // MARK: - Methods
    
    public func create(for flowModel: DictionaryFlowModel) -> DictionaryFlowPresenter {
        
        return DictionaryFlowPresenterImpl(
            flowModel: flowModel,
            listViewFactory: listViewFactory,
            addDictionaryItemFlowPresenterFactory: addDictionaryItemFlowPresenterFactory
        )
    }
}
