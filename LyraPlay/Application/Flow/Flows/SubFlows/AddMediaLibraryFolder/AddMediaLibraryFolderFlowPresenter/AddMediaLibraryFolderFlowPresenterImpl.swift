//
//  AddMediaLibraryFolderFlowPresenterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.09.2022.
//

import Foundation
import Combine
import UIKit

public final class AddMediaLibraryFolderFlowPresenterImpl: AddMediaLibraryFolderFlowPresenter {

    // MARK: - Properties

    private let flowModel: AddMediaLibraryFolderFlowModel

    private let promptFolderNameViewFactory: PromptDialogViewFactory
    
    private var observers = Set<AnyCancellable>()
    
    private var activePromptFolderNameView: PromptDialogViewController?

    // MARK: - Initializers

    public init(
        flowModel: AddMediaLibraryFolderFlowModel,
        promptFolderNameViewFactory: PromptDialogViewFactory
    ) {

        self.flowModel = flowModel
        self.promptFolderNameViewFactory = promptFolderNameViewFactory
    }
    
    deinit {
        observers.removeAll()
    }
}

// MARK: - Input Methods

extension AddMediaLibraryFolderFlowPresenterImpl {

    public func present(at container: UINavigationController) {

        flowModel.promptFolderNameViewModel
            .receive(on: RunLoop.main)
            .sink { [weak self] promptFolderNameViewModel in
                
                guard let self = self else {
                    return
                }
                
                guard let promptFolderNameViewModel = promptFolderNameViewModel else {
                    
                    self.activePromptFolderNameView?.dismiss(animated: true)
                    self.activePromptFolderNameView = nil
                    return
                }
                
                let view = self.promptFolderNameViewFactory.make(viewModel: promptFolderNameViewModel)
                self.activePromptFolderNameView = view
                view.modalTransitionStyle = .crossDissolve
                view.modalPresentationStyle = .custom
                
                container.present(view, animated: true)
                
            }.store(in: &observers)
    }

    public func dismiss() {

        activePromptFolderNameView?.dismiss(animated: true)
        activePromptFolderNameView = nil
    }
}

// MARK: - Output Methods

extension AddMediaLibraryFolderFlowPresenterImpl {

}
