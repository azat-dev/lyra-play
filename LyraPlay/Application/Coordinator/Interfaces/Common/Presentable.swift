//
//  Presentable.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation
import UIKit

public protocol Presentable {
    
    func toPresent() -> PresentableView
}
