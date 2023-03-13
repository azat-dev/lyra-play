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
    private let mediaFilesExtensions: [String]
    
    // MARK: - Initializers

    public init(
        dictionaryArchiveExtension: String,
        mediaFilesExtensions: [String]
    ) {
        
        self.dictionaryArchiveExtension = dictionaryArchiveExtension
        self.mediaFilesExtensions = mediaFilesExtensions
    }

    // MARK: - Methods

    public func make(applicationFlowModel: ApplicationFlowModel) -> DeepLinksHandlerFlowModel {
        
        let router = DeepLinkRouterImpl(
            routes: [
                .init(
                    matcher: ExtensionDeepLinkRouteMatcher(dictionaryArchiveExtension),
                    handler: ImportDictionaryArchiveRouteHandler()
                ),
                .init(
                    matcher: ExtensionDeepLinkRouteMatcher(mediaFilesExtensions),
                    handler: MediaFileRouteHandler()
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
