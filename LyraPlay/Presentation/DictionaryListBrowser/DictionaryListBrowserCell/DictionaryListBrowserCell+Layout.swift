//
//  DictionaryListBrowserCell+Layout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.08.22.
//

import Foundation
import UIKit

extension DictionaryListBrowserCell {

    final class Layout {
        
        static func apply(
            contentView: UIView,
            textGroup: UIStackView,
            titleLabel: UILabel,
            descriptionLabel: UILabel
        ) {
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            textGroup.translatesAutoresizingMaskIntoConstraints = false
            
            textGroup.constraintTo(view: contentView)
        }
    }
}
