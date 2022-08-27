//
//  PresentableModule.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 25.08.22.
//

import Foundation
import UIKit

// MARK: - Interfaces

public protocol PresentableModule: Presentable {
    
    associatedtype ViewModel
    
    var view: Presentable { get }
    
    var model: ViewModel { get }
}

extension PresentableModule {
    
    public func toPresent() -> UIViewController {
        return view.toPresent()
    }
}

// MARK: - Implementations

public struct PresentableModuleImpl<ViewModel>: PresentableModule {
    
    public typealias ViewModel = ViewModel
    
    public var view: Presentable
    
    public var model: ViewModel
    
    public init(view: Presentable, model: ViewModel) {
        
        self.view = view
        self.model = model
    }
}
