//
//  PresentationContainer.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 25.08.22.
//

import Foundation

public protocol PresentationContainer {
    
    func present(_ presentable: Presentable)
    
    func presentModally(_ presentable: Presentable)
}
