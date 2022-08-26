//
//  PresentableModule.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 25.08.22.
//

import Foundation

// MARK: - Interfaces

public protocol PresentableModule {
    
    associatedtype ViewModel
    
    var view: Presentable { get }
    
    var model: ViewModel { get }
}

// MARK: - Implementations

public struct PresentableModuleImpl<ViewModel>: PresentableModule {
    
    public typealias ViewModel = ViewModel
    
    public var view: Presentable
    
    public var model: ViewModel
}
