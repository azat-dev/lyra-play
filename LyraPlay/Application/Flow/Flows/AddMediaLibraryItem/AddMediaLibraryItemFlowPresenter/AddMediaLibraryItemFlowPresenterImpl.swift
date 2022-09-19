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
    
    private var observers = Set<AnyCancellable>()
    
    private var activeChooseItemTypeView: UIViewController?
    private var importMediaFilesPresenter: ImportMediaFilesFlowPresenter?

    // MARK: - Initializers

    public init(
        flowModel: AddMediaLibraryItemFlowModel,
        chooseDialogViewFactory: ChooseDialogViewFactory,
        importMediaFilesFlowPresenterFactory: ImportMediaFilesFlowPresenterFactory
    ) {

        self.flowModel = flowModel
        self.chooseDialogViewFactory = chooseDialogViewFactory
        self.importMediaFilesFlowPresenterFactory = importMediaFilesFlowPresenterFactory
    }
    
    deinit {
        observers.removeAll()
    }
}

// MARK: - Input Methods

extension AddMediaLibraryItemFlowPresenterImpl {

    public func present(at container: UINavigationController) {

        flowModel.chooseItemTypeViewModel
            .receive(on: RunLoop.main)
            .sink { [weak self] chooseItemTypeViewModel in
                
                guard let self = self else {
                    return
                }
                
                guard let chooseItemTypeViewModel = chooseItemTypeViewModel else {
                    
                    self.activeChooseItemTypeView?.dismiss(animated: true)
                    self.activeChooseItemTypeView = nil
                    return
                }
                
                let view = self.chooseDialogViewFactory.create(viewModel: chooseItemTypeViewModel)
                self.activeChooseItemTypeView = view
                
                container.present(view, animated: true)
                
            }.store(in: &observers)
        
        flowModel.importMediaFilesFlow
            .receive(on: RunLoop.main)
            .sink { [weak self] importMediaFilesFlow in
                
                guard let self = self else {
                    return
                }
                
                guard let flow = importMediaFilesFlow else {
                    
                    self.importMediaFilesPresenter?.dismiss()
                    self.importMediaFilesPresenter = nil
                    return
                }
                
                let presenter = self.importMediaFilesFlowPresenterFactory.create(for: flow)
                
                self.importMediaFilesPresenter = presenter
                presenter.present(at: container)
            }
            .store(in: &observers)
    }
    
    public func dismiss() {
        
        activeChooseItemTypeView?.dismiss(animated: true)
        activeChooseItemTypeView = nil
    }
}
