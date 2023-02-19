//
//  LibraryFolderFlowPresenterFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation

public protocol LibraryFolderFlowPresenterFactory {
    
    func make(for flowModel: LibraryFolderFlowModel) -> LibraryFolderFlowPresenter
}

