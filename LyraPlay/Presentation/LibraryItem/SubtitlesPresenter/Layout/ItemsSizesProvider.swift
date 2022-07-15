//
//  ItemsSizesProvider.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.07.22.
//

import Foundation
import UIKit

// MARK: - Interfaces

public protocol ItemsSizesProvider {
    
    func getItemSize(section: Int, item: Int) -> CGSize
    
    var numberOfSections: Int { get }
    
    func numberOfItems(section: Int) -> Int
}