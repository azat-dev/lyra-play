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
    private let exportDictionaryFlowPresenterFactory: ExportDictionaryFlowPresenterFactory
    
    private var observers = Set<AnyCancellable>()
    
    private var addDictionaryItemPresenter: AddDictionaryItemFlowPresenter?
    private var exportDictionaryFlowPresenter: ExportDictionaryFlowPresenter?
    
    // MARK: - Initializers
    
    public init(
        flowModel: DictionaryFlowModel,
        listViewFactory: DictionaryListBrowserViewFactory,
        addDictionaryItemFlowPresenterFactory: AddDictionaryItemFlowPresenterFactory,
        exportDictionaryFlowPresenterFactory: ExportDictionaryFlowPresenterFactory
    ) {
        
        self.flowModel = flowModel
        self.listViewFactory = listViewFactory
        self.addDictionaryItemFlowPresenterFactory = addDictionaryItemFlowPresenterFactory
        self.exportDictionaryFlowPresenterFactory = exportDictionaryFlowPresenterFactory
    }
    
    deinit {
        
        observers.removeAll()
    }
}

// MARK: - Methods

extension DictionaryFlowPresenterImpl {
    
    public func present(at container: UINavigationController) {
        
        let listView = listViewFactory.make(viewModel: flowModel.listViewModel)
        
        flowModel.addDictionaryItemFlow
            .receive(on: DispatchQueue.main)
            .sink { [weak self] addDictionaryItemFlow in
                
                guard let self = self else {
                    return
                }
                
                guard let flow = addDictionaryItemFlow else {

                    self.addDictionaryItemPresenter?.dismiss()
                    self.addDictionaryItemPresenter = nil
                    return
                }

                let presenter = self.addDictionaryItemFlowPresenterFactory.make(for: flow)

                self.addDictionaryItemPresenter = presenter
                presenter.present(at: container)
            }
            .store(in: &observers)
        
        flowModel.exportDictionaryFlow
            .receive(on: DispatchQueue.main)
            .sink { [weak self] exportDictionaryFlow in
                
                guard let self = self else {
                    return
                }
                
                guard let flow = exportDictionaryFlow else {

                    self.exportDictionaryFlowPresenter?.dismiss()
                    self.exportDictionaryFlowPresenter = nil
                    return
                }

                let presenter = self.exportDictionaryFlowPresenterFactory.make(for: flow)

                self.exportDictionaryFlowPresenter = presenter
                presenter.present(at: container, popoverElement: listView.navigationItem.leftBarButtonItem)
            }
            .store(in: &observers)
        
        
        container.pushViewController(listView, animated: true)
    }
}
