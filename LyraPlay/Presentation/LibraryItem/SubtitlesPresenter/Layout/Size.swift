//
//  Size.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.07.22.
//

import Foundation

public struct Size: Equatable {
    
    public var width: Double
    public var height: Double
    
    public init(width: Double, height: Double) {

        self.width = width
        self.height = height
    }
}
