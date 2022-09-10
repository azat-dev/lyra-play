//
//  PresentationContainer.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 25.08.22.
//

import Foundation

public protocol PresentationContainer: AnyObject {
    
    func present(_ presentable: Presentable)
    
    func presentModally(_ presentable: Presentable)
}
