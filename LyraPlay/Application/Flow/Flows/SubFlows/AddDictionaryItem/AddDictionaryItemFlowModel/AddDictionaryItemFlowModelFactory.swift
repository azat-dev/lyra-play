//
//  AddDictionaryItemFlowModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

public protocol AddDictionaryItemFlowModelFactory {

    func make(
        originalText: String?,
        delegate: AddDictionaryItemFlowModelDelegate
    ) -> AddDictionaryItemFlowModel
}
