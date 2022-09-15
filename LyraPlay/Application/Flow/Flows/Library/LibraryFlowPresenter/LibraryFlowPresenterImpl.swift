//
//  LibraryFlowPresenterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation
import UIKit
import Combine

public final class LibraryFlowPresenterImpl: LibraryFlowPresenter {
    
    // MARK: - Properties
    
    private let flowModel: LibraryFlowModel
    
    private let listViewFactory: MediaLibraryBrowserViewFactory
    private let libraryItemFlowPresenterFactory: LibraryItemFlowPresenterFactory
    private let importMediaFilesFlowPresenterFactory: ImportMediaFilesFlowPresenterFactory
    private let deleteMediaLibraryItemFlowPresenterFactory: DeleteMediaLibraryItemFlowPresenterFactory
    
    private var itemFlowPresenter: LibraryItemFlowPresenter?
    private var importFlowPresenter: ImportMediaFilesFlowPresenter?
    private var deleteMediaLibraryItemFlowPresenter: DeleteMediaLibraryItemFlowPresenter?
    
    private var observers = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    public init(
        flowModel: LibraryFlowModel,
        listViewFactory: MediaLibraryBrowserViewFactory,
        libraryItemFlowPresenterFactory: LibraryItemFlowPresenterFactory,
        importMediaFilesFlowPresenterFactory: ImportMediaFilesFlowPresenterFactory,
        deleteMediaLibraryItemFlowPresenterFactory: DeleteMediaLibraryItemFlowPresenterFactory
    ) {
        
        self.flowModel = flowModel
        self.listViewFactory = listViewFactory
        self.libraryItemFlowPresenterFactory = libraryItemFlowPresenterFactory
        self.importMediaFilesFlowPresenterFactory = importMediaFilesFlowPresenterFactory
        self.deleteMediaLibraryItemFlowPresenterFactory = deleteMediaLibraryItemFlowPresenterFactory
    }
    
    deinit {
        
        self.itemFlowPresenter = nil
        self.importFlowPresenter = nil
        
        observers.removeAll()
    }
}

// MARK: - Methods

extension LibraryFlowPresenterImpl {
    
    public func present(at container: UINavigationController) {
        
        flowModel.libraryItemFlow
            .receive(on: RunLoop.main)
            .sink { [weak self] itemFlow in
                
                guard let self = self else {
                    return
                }
                
                guard let itemFlow = itemFlow else {
                    
                    self.itemFlowPresenter?.dismiss()
                    self.itemFlowPresenter = nil
                    return
                }
                
                let presenter = self.libraryItemFlowPresenterFactory.create(for: itemFlow)
                presenter.present(at: container)
                
                self.itemFlowPresenter = presenter
            }.store(in: &observers)
        
        flowModel.importMediaFilesFlow
            .receive(on: RunLoop.main)
            .sink { [weak self] importFlowModel in
                
                guard let self = self else {
                    return
                }
                
                guard let importFlowModel = importFlowModel else {
                    
                    self.self.importFlowPresenter?.dismiss()
                    self.importFlowPresenter = nil
                    return
                }
                
                let presenter = self.importMediaFilesFlowPresenterFactory.create(for: importFlowModel)
                presenter.present(at: container)
                
                self.importFlowPresenter = presenter
            }.store(in: &observers)
        
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
