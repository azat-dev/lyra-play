//
//  ImportDictionaryArchiveRouteHandler.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.01.23.
//

import Foundation


public class ImportDictionaryArchiveRouteHandler: DeepLinkRouteHandler {
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func handle(
        deepLink: DeepLink,
        applicationFlowModel: ApplicationFlowModel
    ) {
        
        applicationFlowModel.runImportDictionaryArchiveFlow(url: deepLink)
    }
}
