//
//  SubtitlesPresenterView+Layout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 16.07.22.
//

import Foundation
import UIKit

extension SubtitlesPresenterView {
    
    final class Layout {
        
        static func apply(
            view: UIView,
            collectionView: UICollectionView
        ) {
            
            collectionView.constraintTo(view: view)
        }
    }
}
