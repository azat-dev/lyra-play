//
//  ExtensionDeepLinkRouteMatcher.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.01.23.
//

import Foundation

public struct ExtensionDeepLinkRouteMatcher: DeepLinkRouteMatcher {
    
    // MARK: - Properties
    
    private let linkExtension: String
    
    // MARK: - Initializers
    
    public init(_ linkExtension: String) {
        
        self.linkExtension = linkExtension.lowercased()
    }
    
    // MARK: - Methods
    
    public func match(deepLink: DeepLink) -> Bool {
        
        return deepLink.pathExtension.lowercased() == linkExtension
    }
}
