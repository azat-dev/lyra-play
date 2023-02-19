//
//  DeepLinkRouteMatcher.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.01.23.
//

import Foundation

public protocol DeepLinkRouteMatcher {
    
    func match(deepLink: DeepLink) -> Bool
}
