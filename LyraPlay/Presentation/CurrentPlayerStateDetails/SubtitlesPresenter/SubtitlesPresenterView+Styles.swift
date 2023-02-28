//
//  SubtitlesPresenterView+Styles.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 16.07.22.
//

import Foundation
import UIKit

extension SubtitlesPresenterView {
    
    final class Styles {
        
        static func apply(collectionView: UICollectionView) {
            
            collectionView.backgroundColor = .clear
            collectionView.backgroundView = nil
        }
    }
}
