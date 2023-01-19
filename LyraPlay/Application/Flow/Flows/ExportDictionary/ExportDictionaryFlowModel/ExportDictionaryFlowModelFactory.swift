//
//  ExportDictionaryFlowModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.01.2023.
//

public protocol ExportDictionaryFlowModelFactory {

    func create(
        originalText: String?,
        delegate: ExportDictionaryFlowModelDelegate
    ) -> ExportDictionaryFlowModel
}