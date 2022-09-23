//
//  LibraryFolderFlowPresenterFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.09.22.
//

import Foundation

public protocol LibraryFolderFlowPresenterFactory {
    
    func create(for: LibraryFolderFlowModel) -> LibraryFolderFlowPresenter
}
