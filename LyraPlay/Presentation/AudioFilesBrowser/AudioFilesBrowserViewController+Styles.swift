//
//  AudioFileBrowserViewController+Styles.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.06.22.
//

import Foundation
import UIKit

extension AudioFilesBrowserViewController {
    
    final class Styles {
        
        static func apply(navigationItem: UINavigationItem) {
            
            navigationItem.title = "Library"
            navigationItem.largeTitleDisplayMode = .always
        }
    }
}
