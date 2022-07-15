//
//  AvailableItemsSizesProvider.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.07.22.
//

import Foundation
import UIKit

public typealias DirectionSize = CGFloat

public protocol AvailableItemsSizesProvider {
    
    func getSize(index: Int, availableSpace: DirectionSize) -> DirectionSize?
}
