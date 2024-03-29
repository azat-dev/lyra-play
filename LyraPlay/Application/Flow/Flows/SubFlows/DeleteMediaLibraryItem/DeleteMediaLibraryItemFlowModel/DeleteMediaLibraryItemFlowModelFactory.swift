//
//  DeleteMediaLibraryItemFlowModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation

public protocol DeleteMediaLibraryItemFlowModelFactory {

    func make(
        itemId: UUID,
        delegate: DeleteMediaLibraryItemFlowDelegate
    ) -> DeleteMediaLibraryItemFlowModel
}
