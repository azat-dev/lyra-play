//
//  CurrentPlayerStateDetailsViewController+Styles.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.22.
//

import Foundation
import UIKit

extension CurrentPlayerStateDetailsViewController {
    
    final class Styles {

        // MARK: - Properties
        
        private static let colorBackground = UIColor(named: "Color.Background")
        
        // MARK: - Methods
        
        static func apply(contentView: UIView) {
            
            contentView.backgroundColor = colorBackground
        }
        
        static func apply(titleLabel: UILabel) {
            
        }
    }
}
