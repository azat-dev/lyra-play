//
//  ImageViewShadowed.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.07.22.
//

import Foundation
import UIKit

class ImageViewShadowed: UIView {
    
    var shadowView = ShadowView()
    var containerView = ShapedView()
    var imageView = UIImageView()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        setupViews()
        layout()
    }
}

// MARK: - Setup Views

extension ImageViewShadowed {
    
    private func setupViews() {
        
        containerView.addSubview(imageView)
        addSubview(shadowView)
        addSubview(containerView)
    }
}

// MARK: - Layout

extension ImageViewShadowed {
    
    private func layout() {
        
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([

            shadowView.leftAnchor.constraint(equalTo: self.leftAnchor),
            shadowView.rightAnchor.constraint(equalTo: self.rightAnchor),
            shadowView.topAnchor.constraint(equalTo: self.topAnchor),
            shadowView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([

            containerView.leftAnchor.constraint(equalTo: self.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: self.rightAnchor),
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([

            imageView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }
}
