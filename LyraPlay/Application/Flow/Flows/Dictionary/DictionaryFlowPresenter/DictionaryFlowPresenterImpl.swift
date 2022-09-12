//
//  DictionaryFlowPresenterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation
import Combine
import UIKit

public final class DictionaryFlowPresenterImpl: DictionaryFlowPresenter {
    
    // MARK: - Properties
    
    private let flowModel: DictionaryFlowModel
    private let listViewFactory: DictionaryListBrowserViewFactory
    private let addDictionaryItemFlowPresenterFactory: AddDictionaryItemFlowPresenterFactory
    
    private var observers = Set<AnyCancellable>()
    private var addDictionaryItemPresenter: AddDictionaryItemFlowPresenter?
    
    // MARK: - Initializers
    
    public init(
        flowModel: DictionaryFlowModel,
        listViewFactory: DictionaryListBrowserViewFactory,
        addDictionaryItemFlowPresenterFactory: AddDictionaryItemFlowPresenterFactory
    ) {
        
        self.flowModel = flowModel
        self.listViewFactory = listViewFactory
        self.addDictionaryItemFlowPresenterFactory = addDictionaryItemFlowPresenterFactory
    }
    
    deinit {
        
        observers.removeAll()
    }
}

// MARK: - Methods

extension DictionaryFlowPresenterImpl {
    
    public func present(at container: UINavigationController) {
        
        flowModel.addDictionaryItemFlow
            .receive(on: RunLoop.main)
            .sink { [weak self] addDictionaryItemFlow in
                
                guard let self = self else {
                    return
                }
                
                guard let flow = addDictionaryItemFlow else {

                    self.addDictionaryItemPresenter?.dismiss()
                    self.addDictionaryItemPresenter = nil
                    return
                }

                let presenter = self.addDictionaryItemFlowPresenterFactory.create(for: flow)

                self.addDictionaryItemPresenter = presenter
                presenter.present(at: container)
            }
            .store(in: &observers)
        
        let view = listViewFactory.create(viewModel: flowModel.listViewModel)
        container.pushViewController(view, animated: true)
    }
}
