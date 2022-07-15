//
//  ItemsPlacer.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.07.22.
//

import Foundation

public protocol ItemsPlacer {
    
    func fillDirection(limit: DirectionSize) -> [DirectionSize]
}
