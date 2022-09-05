//
//  StackPresentationContainer.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 25.08.22.
//

import Foundation

public protocol StackPresentationContainer: PresentationContainer {
    
    func setRoot(_ presentable: Presentable)
    
    func push(_ presentable: Presentable)
    
    func pop()
    
    var items: [Presentable] { get set }
}
