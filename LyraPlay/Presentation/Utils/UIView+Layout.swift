//
//  UIView+Layout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation
import UIKit

extension UIView {
    
    func disableAutoConstraints() {
        
        guard translatesAutoresizingMaskIntoConstraints else {
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func constraintTo(view: UIView, margins: UIEdgeInsets = .zero) {
        
        disableAutoConstraints()
        
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
        
        disableAutoConstraints()
        
        NSLayoutConstraint.activate([
            
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @discardableResult
    func constraintToBottom(view: UIView, spacing: CGFloat = .zero) -> NSLayoutConstraint {
    
        view.disableAutoConstraints()
        
        return NSLayoutConstraint(
            item: view,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1,
            constant: spacing
        ).activated()
    }
    
    @discardableResult
    func constraintToBottom(of view: UIView, spacing: CGFloat = .zero) -> NSLayoutConstraint {
    
        view.disableAutoConstraints()
        
        return NSLayoutConstraint(
            item: self,
            attribute: .top,
            relatedBy: .equal,
            toItem: view,
            attribute: .bottom,
            multiplier: 1,
            constant: spacing
        ).activated()
    }
    
    func constraintToHorizontalEdges(of view: UIView, leftMargin: CGFloat = .zero, rightMargin: CGFloat = .zero) {
        
        disableAutoConstraints()
        
        NSLayoutConstraint.activate([
            
            self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: leftMargin),
            self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -rightMargin),
        ])
    }
    
    func constraintToVerticalEdges(of view: UIView, topMargin: CGFloat = .zero, bottomMargin: CGFloat = .zero) {

        disableAutoConstraints()
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: topMargin),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomMargin),
        ])
    }
}

extension NSLayoutConstraint {
    
    @discardableResult
    func activated() -> NSLayoutConstraint{
        
        NSLayoutConstraint.activate([
            self
            ])
        
//        self.isActive = true
        return self
    }
    
    @discardableResult
    func constraintToBottom(view: UIView, spacing: CGFloat = .zero) -> NSLayoutConstraint {
        
        view.disableAutoConstraints()
        
        return NSLayoutConstraint(
            item: view,
            attribute: .top,
            relatedBy: .equal,
            toItem: self.firstItem,
            attribute: .bottom,
            multiplier: 1,
            constant: spacing
        ).activated()
    }
}
