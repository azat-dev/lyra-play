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
    
    public func route(deepLinks: [DeepLink]) {
        
        for route in routes {
            
            guard route.matcher.match(deepLinks: deepLinks) else {
                continue
            }
            
            route.handler.handle(
                deepLinks: deepLinks,
                applicationFlowModel: applicationFlowModel
            )
            return
        }
    }
}
