//
//  TabBarPresentationContainer.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 25.08.22.
//

import Foundation

public protocol TabBarPresentationContainer: PresentationContainer {
    
    var items: [Presentable] { get }
    
    var activeItemIndex: Int? { get set }
    
    var onDidChangeTab: ((Int) -> Void)? { get set }
}
