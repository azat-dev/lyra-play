//
//  BaseCoordinator.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.22.
//

import Foundation

public class BaseCoordinator: Coordinator {
    
    public var children: [Coordinator] = []
    
    public init() {}
    
    public func addChild(_ child: Coordinator) {
        
        guard children.contains(where: { $0 === child }) else {
            return
        }
        
        children.append(child)
    }
    
    public func removeChild(_ child: Coordinator) {
        
        children.removeAll(where: { $0 === child })
    }
}
