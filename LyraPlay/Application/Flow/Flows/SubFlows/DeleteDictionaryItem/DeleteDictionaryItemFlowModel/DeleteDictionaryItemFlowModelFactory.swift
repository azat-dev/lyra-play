//
//  DeleteDictionaryItemFlowModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.09.2022.
//

import Foundation

public protocol DeleteDictionaryItemFlowModelFactory {

    func make(
        itemId: UUID,
        delegate: DeleteDictionaryItemFlowDelegate
    ) -> DeleteDictionaryItemFlowModel
}
