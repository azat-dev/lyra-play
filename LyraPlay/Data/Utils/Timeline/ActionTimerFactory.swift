//
//  ActionTimerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.07.22.
//

import Foundation

// MARK: - Interfaces

public protocol ActionTimerFactory {
    
    func create() -> ActionTimer
}

// MARK: - Implementations

public final class ActionTimerFactoryImpl: ActionTimerFactory {
    
    public init() { }
    
    public func create() -> ActionTimer {
        
        return ActionTimerImpl()
    }
}
