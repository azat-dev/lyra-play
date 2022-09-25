//
//  UIWindow+Utils.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation
import UIKit

extension UIWindow: WindowContainer {

    public func setRoot(_ view: PresentableView) {
        
        guard let vc = view.toPresent() as? UIViewController else {
            return
        }
     
        rootViewController = vc
    }
}
