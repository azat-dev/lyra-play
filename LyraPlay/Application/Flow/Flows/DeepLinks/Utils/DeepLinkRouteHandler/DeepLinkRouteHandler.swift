//
//  DeepLinkRouteHandler.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.01.23.
//

import Foundation

public protocol DeepLinkRouteHandler {
    
    func handle(
        deepLink: DeepLink,
        applicationFlowModel: ApplicationFlowModel
    )
}
