//
//  UINavigationController+Utills.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.22.
//

import Foundation
import UIKit

extension UINavigationController: StackPresentationContainer {
    
    
    public func setRoot(_ presentable: Presentable) {
        
        guard let vc = presentable.toPresent() as? UIViewController else {
            return
        }
        
        pushViewController(vc, animated: false)
    }
    
    public func push(_ presentable: Presentable) {

        guard let vc = presentable.toPresent() as? UIViewController else {
            return
        }
        
        pushViewController(vc, animated: true)
    }
    
    public func pop() {
        
        popViewController(animated: true)
    }
    
    public var items: [Presentable] {
        
        get {
            return viewControllers
        }
        
        set {
            viewControllers = newValue.map { $0.toPresent() as! UIViewController }
        }
    }
    
    public func present(_ presentable: Presentable) {
        fatalError()
    }
    
    public func presentModally(_ presentable: Presentable) {
        fatalError()
    }
}
