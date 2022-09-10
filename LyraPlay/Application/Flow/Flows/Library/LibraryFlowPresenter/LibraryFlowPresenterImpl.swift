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
    
    private let listViewFactory: AudioFilesBrowserViewFactory
    private let libraryItemFlowPresenterFactory: LibraryItemFlowPresenterFactory
    private let importMediaFilesFlowPresenterFactory: ImportMediaFilesFlowPresenterFactory
    
    private var libraryItemFlowObserver: AnyCancellable?
    private var itemFlowPresenter: LibraryItemFlowPresenter?

    private var importFlowObserver: AnyCancellable?
    private var importFlowPresenter: ImportMediaFilesFlowPresenter?
    
    // MARK: - Initializers
    
    public init(
        flowModel: LibraryFlowModel,
        listViewFactory: AudioFilesBrowserViewFactory,
        libraryItemFlowPresenterFactory: LibraryItemFlowPresenterFactory,
        importMediaFilesFlowPresenterFactory: ImportMediaFilesFlowPresenterFactory
    ) {
        
        self.flowModel = flowModel
        self.listViewFactory = listViewFactory
        self.libraryItemFlowPresenterFactory = libraryItemFlowPresenterFactory
        self.importMediaFilesFlowPresenterFactory = importMediaFilesFlowPresenterFactory
    }
}

// MARK: - Methods

extension LibraryFlowPresenterImpl {
    
    public func present(at container: UINavigationController) {
        
        libraryItemFlowObserver = flowModel.libraryItemFlow
            .receive(on: RunLoop.main)
            .sink { [weak self] itemFlow in
                
                guard let self = self else {
                    return
                }
                
                guard let itemFlow = itemFlow else {
                    
                    self.itemFlowPresenter = nil
                    return
                }
                
                let presenter = self.libraryItemFlowPresenterFactory.create(for: itemFlow)
                presenter.present(at: container)
                
                self.itemFlowPresenter = presenter
            }
        
        importFlowObserver = flowModel.importMediaFilesFlow
            .receive(on: RunLoop.main)
            .sink { [weak self] importFlowModel in
                
                guard let self = self else {
                    return
                }
                
                guard let importFlowModel = importFlowModel else {
                    
                    self.importFlowPresenter = nil
                    return
                }
                
                let presenter = self.importMediaFilesFlowPresenterFactory.create(for: importFlowModel)
                presenter.present(at: container)
                
                self.importFlowPresenter = presenter
            }
        
        let view = listViewFactory.create(viewModel: flowModel.listViewModel)
        container.pushViewController(view, animated: true)
    }
}
