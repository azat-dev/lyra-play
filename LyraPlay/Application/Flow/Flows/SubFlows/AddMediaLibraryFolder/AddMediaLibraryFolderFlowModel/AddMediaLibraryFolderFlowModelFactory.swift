//
//  AddMediaLibraryFolderFlowModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation

public protocol AddMediaLibraryFolderFlowModelFactory {

    func create(
        targetFolderId: UUID?,
        delegate: AddMediaLibraryFolderFlowModelDelegate
    ) -> AddMediaLibraryFolderFlowModel
}
