//
//  AddMediaLibraryItemFlowPresenterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation
import Combine
import UIKit

public final class AddMediaLibraryItemFlowPresenterImpl: AddMediaLibraryItemFlowPresenter {

    // MARK: - Properties

    private let flowModel: AddMediaLibraryItemFlowModel

    private let chooseDialogViewFactory: ChooseDialogViewFactory
    private let importMediaFilesFlowPresenterFactory: ImportMediaFilesFlowPresenterFactory
    private let addMediaLibraryFolderFlowPresenterFactory: AddMediaLibraryFolderFlowPresenterFactory
    
    private var observers = Set<AnyCancellable>()
    
    private var activeChooseItemTypeView: UIViewController?
    private var importMediaFilesPresenter: ImportMediaFilesFlowPresenter?
    
    private var addMediaLibraryFolderPresenter: AddMediaLibraryFolderFlowPresenter?

    // MARK: - Initializers

    public init(
        flowModel: AddMediaLibraryItemFlowModel,
        chooseDialogViewFactory: ChooseDialogViewFactory,
        importMediaFilesFlowPresenterFactory: ImportMediaFilesFlowPresenterFactory,
        addMediaLibraryFolderFlowPresenterFactory: AddMediaLibraryFolderFlowPresenterFactory
    ) {

        self.flowModel = flowModel
        self.chooseDialogViewFactory = chooseDialogViewFactory
        self.importMediaFilesFlowPresenterFactory = importMediaFilesFlowPresenterFactory
        self.addMediaLibraryFolderFlowPresenterFactory = addMediaLibraryFolderFlowPresenterFactory
    }
    
    deinit {
        observers.removeAll()
    }
}

// MARK: - Input Methods

extension AddMediaLibraryItemFlowPresenterImpl {

    public func present(at container: UINavigationController) {

        flowModel.chooseItemTypeViewModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] chooseItemTypeViewModel in
                
                guard let self = self else {
                    return
                }
                
                guard let chooseItemTypeViewModel = chooseItemTypeViewModel else {
                    
                    self.activeChooseItemTypeView?.dismiss(animated: true)
                    self.activeChooseItemTypeView = nil
                    return
                }
                
                let view = self.chooseDialogViewFactory.make(viewModel: chooseItemTypeViewModel)
                self.activeChooseItemTypeView = view
                
                container.present(view, animated: true)
                
            }.store(in: &observers)
        
        flowModel.importMediaFilesFlow
            .receive(on: DispatchQueue.main)
            .sink { [weak self] importMediaFilesFlow in
                
                guard let self = self else {
                    return
                }
                
                guard let flow = importMediaFilesFlow else {
                    
                    self.importMediaFilesPresenter?.dismiss()
                    self.importMediaFilesPresenter = nil
                    return
                }
                
                let presenter = self.importMediaFilesFlowPresenterFactory.make(for: flow)
                
                self.importMediaFilesPresenter = presenter
                presenter.present(at: container)
            }
            .store(in: &observers)

        flowModel.addMediaLibraryFolderFlow
            .receive(on: DispatchQueue.main)
            .sink { [weak self] addMediaLibraryFolderFlow in
                
                guard let self = self else {
                    return
                }
                
                guard let flow = addMediaLibraryFolderFlow else {
                    
                    self.addMediaLibraryFolderPresenter?.dismiss()
                    self.addMediaLibraryFolderPresenter = nil
                    return
                }
                
                let presenter = self.addMediaLibraryFolderFlowPresenterFactory.make(for: flow)
                
                self.addMediaLibraryFolderPresenter = presenter
                presenter.present(at: container)
            }
            .store(in: &observers)
    }
    
    public func dismiss() {
        
        activeChooseItemTypeView?.dismiss(animated: true)
        activeChooseItemTypeView = nil
        
        importMediaFilesPresenter?.dismiss()
        importMediaFilesPresenter = nil
        
        addMediaLibraryFolderPresenter?.dismiss()
        addMediaLibraryFolderPresenter = nil
    }
}
