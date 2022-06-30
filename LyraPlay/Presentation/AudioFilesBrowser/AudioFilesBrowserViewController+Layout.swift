//
//  AudioFilesBrowserViewController+Layout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.06.22.
//

import Foundation
import UIKit

extension AudioFilesBrowserViewController {
    
    final class Layout {
        
        static func apply(
            view: UIView,
            tableView: UITableView
        ) {
            
            tableView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                
                tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
                tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }
    }
}
