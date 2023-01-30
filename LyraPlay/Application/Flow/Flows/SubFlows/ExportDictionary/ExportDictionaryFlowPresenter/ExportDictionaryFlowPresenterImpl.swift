//
//  ExportDictionaryFlowPresenterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.01.2023.
//

import Foundation
import UIKit

import Combine

public final class ExportDictionaryFlowPresenterImpl: ExportDictionaryFlowPresenter {

    // MARK: - Properties

    private let flowModel: ExportDictionaryFlowModel

    private let fileSharingViewControllerFactory: FileSharingViewControllerFactory
    
    private weak var activeFileSharingView: FileSharingViewController?
    
    private var observers = Set<AnyCancellable>()

    // MARK: - Initializers

    public init(
        flowModel: ExportDictionaryFlowModel,
        fileSharingViewControllerFactory: FileSharingViewControllerFactory
    ) {

        self.flowModel = flowModel
        self.fileSharingViewControllerFactory = fileSharingViewControllerFactory
    }
}

// MARK: - Input Methods

extension ExportDictionaryFlowPresenterImpl {

    public func present(at container: UINavigationController, popoverElement: UIBarButtonItem?) {

        flowModel.fileSharingViewModel
            .receive(on: RunLoop.main)
            .sink { [weak self] fileSharingViewModel in
                
                guard let self = self else {
                    return
                }
                
                guard let fileSharingViewModel = fileSharingViewModel else {
                    
                    self.activeFileSharingView?.dismiss(animated: true)
                    self.activeFileSharingView = nil
                    return
                }
                
                let view = self.fileSharingViewControllerFactory.create(viewModel: fileSharingViewModel)
                self.activeFileSharingView = view
                
                view.popoverPresentationController?.barButtonItem = popoverElement
                container.present(view, animated: true)
            }.store(in: &observers)
    }

    public func dismiss() {

        activeFileSharingView?.dismiss(animated: true)
        activeFileSharingView = nil
    }
}

// MARK: - Output Methods

extension ExportDictionaryFlowPresenterImpl {

}
