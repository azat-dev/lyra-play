//
//  DeleteMediaLibraryItemFlowPresenterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation
import Combine
import UIKit

public final class DeleteMediaLibraryItemFlowPresenterImpl: DeleteMediaLibraryItemFlowPresenter {

    // MARK: - Properties

    private let flowModel: DeleteMediaLibraryItemFlowModel
    private let confirmDialogViewFactory: ConfirmDialogViewFactory
    
    private var observers = Set<AnyCancellable>()
    
    private weak var activeConfirmView: UIViewController?

    // MARK: - Initializers

    public init(
        flowModel: DeleteMediaLibraryItemFlowModel,
        confirmDialogViewFactory: ConfirmDialogViewFactory
    ) {

        self.flowModel = flowModel
        self.confirmDialogViewFactory = confirmDialogViewFactory
    }
    
    deinit {
        observers.removeAll()
    }
}

// MARK: - Input Methods

extension DeleteMediaLibraryItemFlowPresenterImpl {

    public func present(at container: UINavigationController) {

        flowModel.confirmDialogViewModel
            .receive(on: RunLoop.main)
            .sink { [weak self] viewModel in
                
                guard let self = self else {
                    return
                }
                
                guard let viewModel = viewModel else {
                    
                    self.activeConfirmView?.dismiss(animated: true)
                    self.activeConfirmView = nil
                    return
                }
                
                let view = self.confirmDialogViewFactory.make(viewModel: viewModel)
                container.present(view, animated: true)
                self.activeConfirmView = view
                
            }.store(in: &observers)
    }
    
    public func dismiss() {
        
        activeConfirmView?.dismiss(animated: true)
        activeConfirmView = nil
    }
}

// MARK: - Output Methods

extension DeleteMediaLibraryItemFlowPresenterImpl {

}
