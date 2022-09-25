//
//  AudioFileBrowserViewController+Styles.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.06.22.
//

import Foundation
import UIKit

extension MediaLibraryBrowserViewController {
    
    final class Styles {
        
        static func apply(navigationItem: UINavigationItem) {
            
            navigationItem.title = "Library"
            navigationItem.largeTitleDisplayMode = .always
        }
        
        static func apply(contentView: UIView) {
            
            contentView.backgroundColor = UIColor(named: "Color.Background")
        }
        
        static func apply(tableView: UITableView) {
            
            tableView.separatorStyle = .none
            tableView.backgroundColor = .clear
            tableView.backgroundView = nil
        }
    }
}
