//
//  UIViewController+Utils.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 02.09.22.
//

import Foundation
import UIKit

extension UIViewController: PresentableView {}

extension UIViewController: Presentable {
    
    public func toPresent() -> PresentableView {
        return self
    }
}
