//
//  DeepLinksHandler.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.01.23.
//

import Foundation

public struct DeepLinkRoute {
    
    public let matcher: DeepLinkRouteMatcher
    public let handler: DeepLinkRouteHandler
}
