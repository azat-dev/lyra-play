//
//  ExtensionDeepLinkRouteMatcher.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.01.23.
//

import Foundation

public struct ExtensionDeepLinkRouteMatcher: DeepLinkRouteMatcher {
    
    // MARK: - Properties
    
    private let linkExtensions: [String]
    
    // MARK: - Initializers
    
    public init(_ linkExtension: String) {
        
        self.linkExtensions = [linkExtension.lowercased()]
    }
    
    public init(_ linkExtensions: [String]) {
        
        self.linkExtensions = linkExtensions.map { $0.lowercased() }
    }
    
    // MARK: - Methods
    
    public func match(deepLink: DeepLink) -> Bool {
        
        return linkExtensions.contains(deepLink.pathExtension.lowercased())
    }
}
