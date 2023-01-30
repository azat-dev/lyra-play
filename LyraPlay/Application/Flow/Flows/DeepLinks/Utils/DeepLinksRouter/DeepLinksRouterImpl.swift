//
//  DeepLinksRouterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.01.23.
//

import Foundation

public class DeepLinkRouterImpl: DeepLinksRouter {
    
    // MARK: - Properties
    
    private let routes: [DeepLinkRoute]
    private let applicationFlowModel: ApplicationFlowModel
    
    // MARK: - Initializers
    
    public init(
        routes: [DeepLinkRoute],
        applicationFlowModel: ApplicationFlowModel
    ) {
        
        self.routes = routes
        self.applicationFlowModel = applicationFlowModel
    }
    
    // MARK: - Methods
    
    public func route(deepLink: DeepLink) {
        
        for route in routes {
            
            guard route.matcher.match(deepLink: deepLink) else {
                continue
            }
            
            route.handler.handle(
                deepLink: deepLink,
                applicationFlowModel: applicationFlowModel
            )
            return
        }
    }
}
