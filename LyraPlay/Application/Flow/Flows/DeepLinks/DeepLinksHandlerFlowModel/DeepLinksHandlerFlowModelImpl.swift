//
//  DeepLinksHandlerFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.01.2023.
//

import Foundation

public final class DeepLinksHandlerFlowModelImpl: DeepLinksHandlerFlowModel {

    // MARK: - Properties

    private let applicationFlowModel: ApplicationFlowModel
    private let router: DeepLinksRouter
    
    // MARK: - Initializers

    public init(
        applcationFlowModel: ApplicationFlowModel,
        router: DeepLinksRouter
    ) {

        self.applicationFlowModel = applcationFlowModel
        self.router = router
    }
}

// MARK: - Input Methods

extension DeepLinksHandlerFlowModelImpl {

    public func handle(urls: [URL]) {

        router.route(deepLinks: urls)
    }
}
