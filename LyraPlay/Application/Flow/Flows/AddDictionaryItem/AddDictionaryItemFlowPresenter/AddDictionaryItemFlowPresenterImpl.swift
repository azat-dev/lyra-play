//
//  AddDictionaryItemFlowPresenterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation
import Combine
import UIKit

public final class AddDictionaryItemFlowPresenterImpl: AddDictionaryItemFlowPresenter {
    
    // MARK: - Properties
    
    private let flowModel: AddDictionaryItemFlowModel
    private let editDictionaryItemViewFactory: EditDictionaryItemViewFactory
    
    private var observers = Set<AnyCancellable>()
    private weak var activeView: UIViewController?
    
    // MARK: - Initializers
    
    public init(
        flowModel: AddDictionaryItemFlowModel,
        editDictionaryItemViewFactory: EditDictionaryItemViewFactory
    ) {
        
        self.flowModel = flowModel
        self.editDictionaryItemViewFactory = editDictionaryItemViewFactory
    }
    
    deinit {
        observers.removeAll()
    }
}

// MARK: - Input Methods

extension AddDictionaryItemFlowPresenterImpl {
    
    public func present(at container: UINavigationController) {
        
        flowModel.editDictionaryItemViewModel
            .receive(on: RunLoop.main)
            .sink { [weak self] editItemViewModel in
                
                guard let self = self else {
                    return
                }
                
                guard let editItemViewModel = editItemViewModel else {
                    
                    self.activeView?.dismiss(animated: true)
                    self.activeView = nil
                    return
                }
                
                let view = self.editDictionaryItemViewFactory.create(viewModel: editItemViewModel)
                self.activeView = view
                
                container.pushViewController(view, animated: true)
                
            }.store(in: &observers)
    }
    
    public func dismiss() {
        
        activeView?.dismiss(animated: true)
    }
}
