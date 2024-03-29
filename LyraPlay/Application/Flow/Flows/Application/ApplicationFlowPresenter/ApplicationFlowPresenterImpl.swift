//
//  ApplicationFlowPresenterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.01.2023.
//

import Foundation
import UIKit

public final class ApplicationFlowPresenterImpl: ApplicationFlowPresenter {

    // MARK: - Properties

    private let flowModel: ApplicationFlowModel
    
    private let mainFlowPresenterFactory: MainFlowPresenterFactory
    
    private var mainPresenter: MainFlowPresenter?

    // MARK: - Initializers

    public init(
        flowModel: ApplicationFlowModel,
        mainFlowPresenterFactory: MainFlowPresenterFactory
    ) {

        self.flowModel = flowModel
        self.mainFlowPresenterFactory = mainFlowPresenterFactory
    }
}

// MARK: - Input Methods

extension ApplicationFlowPresenterImpl {

    public func present(at container: UIWindow) {
        
        let mainPresenter = mainFlowPresenterFactory.make(flowModel: flowModel.mainFlowModel)
        
        self.mainPresenter = mainPresenter
        mainPresenter.present(at: container)
    }

    public func dismiss() {

        fatalError()
    }
}

// MARK: - Output Methods

extension ApplicationFlowPresenterImpl {

}
