//
//  LibraryCoordinatorFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.22.
//

import Foundation

public protocol LibraryCoordinatorFactory {
    
    func create() -> LibraryCoordinator
}
