//
//  ImportDictionaryArchiveFlowModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.01.2023.
//

import Foundation

public protocol ImportDictionaryArchiveFlowModelFactory {
    
    func create(
        url: URL,
        mainFlowModel: MainFlowModel,
        delegate: ImportDictionaryArchiveFlowModelDelegate
    ) -> ImportDictionaryArchiveFlowModel
}
