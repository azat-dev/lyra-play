//
//  DictionaryFlowPresenterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation

public final class DictionaryFlowPresenterImplFactory: DictionaryFlowPresenterFactory {
    
    private let listViewFactory: DictionaryListBrowserViewFactory
    
    public init(listViewFactory: DictionaryListBrowserViewFactory) {
        
        self.listViewFactory = listViewFactory
    }
    
    public func create(for flowModel: DictionaryFlowModel) -> DictionaryFlowPresenter {
        
        return DictionaryFlowPresenterImpl(
            flowModel: flowModel,
            listViewFactory: listViewFactory
        )
    }
}
