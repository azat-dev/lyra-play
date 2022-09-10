//
//  LibraryFlowPresenterFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation

public protocol LibraryFlowPresenterFactory {
    
    func create(for flowModel: LibraryFlowModel) -> LibraryFlowPresenter
}

