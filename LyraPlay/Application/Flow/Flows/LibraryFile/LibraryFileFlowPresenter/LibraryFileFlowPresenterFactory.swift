//
//  LibraryFileFlowPresenterFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.09.22.
//

import Foundation

public protocol LibraryFileFlowPresenterFactory {
    
    func create(for: LibraryFileFlowModel) -> LibraryFileFlowPresenter
}
