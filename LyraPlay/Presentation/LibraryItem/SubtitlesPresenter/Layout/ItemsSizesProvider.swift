//
//  ItemsSizesProvider.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.07.22.
//

import Foundation

// MARK: - Interfaces

protocol ItemsSizesProvider {
    
    func getItemSize(section: Int, item: Int) -> (width: Double, height: Double)
    
    var numberOfSections: Int { get }
    
    func numberOfItems(section: Int) -> Int
}
