//
//  Factory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 23.01.23.
//

import Foundation

public protocol Factory {
    
    associatedtype T
    
    func make() -> T
}

