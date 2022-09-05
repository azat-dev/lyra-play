//
//  Presentable.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public protocol Presentable: AnyObject {
    
    func toPresent() -> PresentableView
}
