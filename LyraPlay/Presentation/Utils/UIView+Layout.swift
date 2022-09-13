//
//  UIView+Layout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation
import UIKit

extension UIView {
    
    func constraintTo(view: UIView, margins: UIEdgeInsets = .zero) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        constraintToHorizontalEdges(
            of: view,
            leftMargin: margins.left,
            rightMargin: margins.right
        )
        
        constraintToVerticalEdges(
            of: view,
            topMargin: margins.top,
            bottomMargin: margins.bottom
        )
    }
    
    func constraintToCenter(of view: UIView) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func constraintToHorizontalEdges(of view: UIView, leftMargin: CGFloat = .zero, rightMargin: CGFloat = .zero) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: leftMargin),
            self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -rightMargin),
        ])
    }
    
    func constraintToVerticalEdges(of view: UIView, topMargin: CGFloat = .zero, bottomMargin: CGFloat = .zero) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: topMargin),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomMargin),
        ])
    }
}
