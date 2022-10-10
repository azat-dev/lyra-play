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
        
        static func apply(tableView: UITableView) {
            
            tableView.separatorStyle = .none
            tableView.backgroundColor = .clear
            tableView.backgroundView = nil
        }
    }
}
