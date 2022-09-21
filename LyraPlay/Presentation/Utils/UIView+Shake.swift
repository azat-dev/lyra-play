//
//  UIView+Shake.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.09.22.
//

import Foundation
import UIKit

extension UIView {

    func shake(maxAmplitude: Double = 20.0, duration: TimeInterval = 0.3) {

        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")

        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = duration
        
        animation.values = [
            -maxAmplitude,
            maxAmplitude,
            -maxAmplitude,
            maxAmplitude,
            -maxAmplitude / 2,
            maxAmplitude / 2,
            -maxAmplitude / 4,
            maxAmplitude / 4,
            0.0
        ]
        layer.add(animation, forKey: "shake")
    }
}
