//
//  LibraryFolderFlowPresenterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation
import UIKit
import Combine

public final class LibraryFolderFlowPresenterImpl: LibraryFolderFlowPresenter {
    
    // MARK: - Properties
    
    private let flowModel: LibraryFolderFlowModel
    
    private let listViewFactory: MediaLibraryBrowserViewFactory
    private let libraryItemFlowPresenterFactory: LibraryFileFlowPresenterFactory
    private let addMediaLibraryItemFlowPresenterFactory: AddMediaLibraryItemFlowPresenterFactory
    private let deleteMediaLibraryItemFlowPresenterFactory: DeleteMediaLibraryItemFlowPresenterFactory
    
    private var itemFlowPresenter: LibraryFileFlowPresenter?
    private var addMediaLibraryItemFlowPresenter: AddMediaLibraryItemFlowPresenter?
    private var deleteMediaLibraryItemFlowPresenter: DeleteMediaLibraryItemFlowPresenter?
    
    private var observers = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    public init(
        flowModel: LibraryFolderFlowModel,
        listViewFactory: MediaLibraryBrowserViewFactory,
        libraryItemFlowPresenterFactory: LibraryFileFlowPresenterFactory,
        addMediaLibraryItemFlowPresenterFactory: AddMediaLibraryItemFlowPresenterFactory,
        deleteMediaLibraryItemFlowPresenterFactory: DeleteMediaLibraryItemFlowPresenterFactory
    ) {
        
        self.flowModel = flowModel
        self.listViewFactory = listViewFactory
        self.libraryItemFlowPresenterFactory = libraryItemFlowPresenterFactory
        self.addMediaLibraryItemFlowPresenterFactory = addMediaLibraryItemFlowPresenterFactory
        self.deleteMediaLibraryItemFlowPresenterFactory = deleteMediaLibraryItemFlowPresenterFactory
    }
    
    deinit {
        
        self.itemFlowPresenter = nil
        self.addMediaLibraryItemFlowPresenter = nil
        
        observers.removeAll()
    }
}

// MARK: - Methods

extension LibraryFolderFlowPresenterImpl {
    
    private func presentFile(flowModel: LibraryFileFlowModel, container: UINavigationController) {
     
        let presenter = self.libraryItemFlowPresenterFactory.create(for: flowModel)
        presenter.present(at: container)
        self.itemFlowPresenter = presenter
    }
    
    public func present(at container: UINavigationController) {
        
        flowModel.libraryItemFlow
            .receive(on: RunLoop.main)
            .sink { [weak self] itemFlow in
                
                guard let self = self else {
                    return
                }
                
                switch itemFlow {
                    
                case .none:
                    self.itemFlowPresenter?.dismiss()
                    self.itemFlowPresenter = nil
                    break
                    
                case .file(let fileFlowModel):
                    self.presentFile(flowModel: fileFlowModel, container: container)
                }
                
            }.store(in: &observers)
        
        flowModel.addMediaLibraryItemFlow
            .receive(on: RunLoop.main)
            .sink { [weak self] addMediaLibraryItemFlow in
                
                guard let self = self else {
                    return
                }
                
                guard let flow = addMediaLibraryItemFlow else {
                    
                    self.addMediaLibraryItemFlowPresenter?.dismiss()
                    self.addMediaLibraryItemFlowPresenter = nil
                    return
                }
                
                let presenter = self.addMediaLibraryItemFlowPresenterFactory.create(for: flow)
                
                self.addMediaLibraryItemFlowPresenter = presenter
                presenter.present(at: container)
            }
            .store(in: &observers)
        
        flowModel.deleteMediaLibraryItemFlow
            .receive(on: RunLoop.main)
            .sink { [weak self] deleteLibraryItemFlow in
                
                guard let self = self else {
                    return
                }
                
                guard let deleteLibraryItemFlow = deleteLibraryItemFlow else {
                    
                    self.deleteMediaLibraryItemFlowPresenter?.dismiss()
                    self.deleteMediaLibraryItemFlowPresenter = nil
                    return
                }
                
                let presenter = self.deleteMediaLibraryItemFlowPresenterFactory.create(for: deleteLibraryItemFlow)
                presenter.present(at: container)
                
                self.deleteMediaLibraryItemFlowPresenter = presenter
            }.store(in: &observers)
        
        let view = listViewFactory.create(viewModel: flowModel.listViewModel)
        container.pushViewController(view, animated: true)
    }
}
