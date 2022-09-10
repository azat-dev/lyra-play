//
//  LibraryItemFlowPresenterFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.09.22.
//

import Foundation

public protocol LibraryItemFlowPresenterFactory {
    
    func create(for: LibraryItemFlowModel) -> LibraryItemFlowPresenter
}
