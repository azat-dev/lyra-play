//
//  Inset.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.07.22.
//

import Foundation

public struct Insets {
    
    public var top: Double
    public var bottom: Double
    public var left: Double
    public var right: Double
    
    public init(top: Double, bottom: Double, left: Double, right: Double) {
        
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
    }
    
    public static let zero = Insets(top: 0, bottom: 0, left: 0, right: 0)
}
