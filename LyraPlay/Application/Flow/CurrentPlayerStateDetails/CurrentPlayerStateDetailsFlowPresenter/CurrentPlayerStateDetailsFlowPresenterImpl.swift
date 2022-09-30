//
//  CurrentPlayerStateDetailsFlowPresenterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

import Foundation
import UIKit

public final class CurrentPlayerStateDetailsFlowPresenterImpl: CurrentPlayerStateDetailsFlowPresenter {

    // MARK: - Properties

    private let flowModel: CurrentPlayerStateDetailsFlowModel

    private let currentPlayerStateDetailsViewControllerFactory: CurrentPlayerStateDetailsViewControllerFactory
    
    private weak var activeView: UIViewController?

    // MARK: - Initializers

    public init(
        flowModel: CurrentPlayerStateDetailsFlowModel,
        currentPlayerStateDetailsViewControllerFactory: CurrentPlayerStateDetailsViewControllerFactory
    ) {

        self.flowModel = flowModel
        self.currentPlayerStateDetailsViewControllerFactory = currentPlayerStateDetailsViewControllerFactory
    }
}

// MARK: - Input Methods

extension CurrentPlayerStateDetailsFlowPresenterImpl {

    public func present(at container: UINavigationController) {

        let view = currentPlayerStateDetailsViewControllerFactory.create(viewModel: flowModel.currentPlayerStateDetailsViewModel)
        activeView = view

        view.modalPresentationStyle = .overFullScreen
        view.modalTransitionStyle = .coverVertical
        
        container.present(view, animated: true)
    }

    public func dismiss() {

        activeView?.dismiss(animated: true)
        activeView = nil
    }
}

// MARK: - Output Methods

extension CurrentPlayerStateDetailsFlowPresenterImpl {

}
