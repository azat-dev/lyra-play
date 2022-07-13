//
//  UIView+Layout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation
import UIKit

extension UIView {
    
    func constraintTo(view: UIView) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            self.leftAnchor.constraint(equalTo: view.leftAnchor),
            self.rightAnchor.constraint(equalTo: view.rightAnchor),
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
