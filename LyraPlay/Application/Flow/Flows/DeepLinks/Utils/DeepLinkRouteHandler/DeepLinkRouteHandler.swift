//
//  DeepLinkRouteHandler.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.01.23.
//

import Foundation

public protocol DeepLinkRouteHandler {
    
    func handle(
        deepLinks: [DeepLink],
        applicationFlowModel: ApplicationFlowModel
    )
}
