//
//  DeepLinksHandlerFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.01.2023.
//

import Foundation

public final class DeepLinksHandlerFlowModelImplFactory: DeepLinksHandlerFlowModelFactory {

    // MARK: - Initializers
    
    private let dictionaryArchiveExtension: String
    
    // MARK: - Initializers

    public init(
        dictionaryArchiveExtension: String
    ) {
        
        self.dictionaryArchiveExtension = dictionaryArchiveExtension
    }

    // MARK: - Methods

    public func create(applicationFlowModel: ApplicationFlowModel) -> DeepLinksHandlerFlowModel {
        
        let router = DeepLinkRouterImpl(
            routes: [
                .init(
                    matcher: ExtensionDeepLinkRouteMatcher(dictionaryArchiveExtension),
                    handler: ImportDictionaryArchiveRouteHandler()
                )
            ],
            applicationFlowModel: applicationFlowModel
        )
        
        return DeepLinksHandlerFlowModelImpl(
            applcationFlowModel: applicationFlowModel,
            router: router
        )
    }
}
