//
//  AddMediaLibraryItemFlowModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation

public protocol AddMediaLibraryItemFlowModelFactory {

    func create(
        targetFolderId: UUID?,
        delegate: AddMediaLibraryItemFlowModelDelegate
    ) -> AddMediaLibraryItemFlowModel
}
