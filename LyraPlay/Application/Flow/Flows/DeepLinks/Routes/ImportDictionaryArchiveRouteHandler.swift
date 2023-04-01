//
//  ImportDictionaryArchiveRouteHandler.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.01.23.
//

import Foundation


public final class ImportDictionaryArchiveRouteHandler: DeepLinkRouteHandler {
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func handle(
        deepLinks: [DeepLink],
        applicationFlowModel: ApplicationFlowModel
    ) {
        
        guard let deepLink = deepLinks.first else {
            return
        }
        
        applicationFlowModel.runImportDictionaryArchiveFlow(url: deepLink)
    }
}
