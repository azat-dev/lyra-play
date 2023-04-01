//
//  DeepLinksRouter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.01.23.
//

import Foundation

public protocol DeepLinksRouter {
    
    func route(deepLinks: [DeepLink])
}
