//
//  LibraryFileFlowPresenter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.09.22.
//

import Foundation
import UIKit

public protocol LibraryFileFlowPresenter {
 
    func present(at: UINavigationController)
    
    func dismiss()
}
