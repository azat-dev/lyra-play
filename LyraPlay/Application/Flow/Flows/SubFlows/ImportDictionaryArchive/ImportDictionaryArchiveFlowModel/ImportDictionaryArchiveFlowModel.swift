//
//  ImportDictionaryArchiveFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.01.2023.
//

import Foundation

public protocol ImportDictionaryArchiveFlowModelDelegate: AnyObject {
    
    func importDictionaryArchiveFlowModelDidDispose()
}


public protocol ImportDictionaryArchiveFlowModelInput: AnyObject {

    func start()
}

public protocol ImportDictionaryArchiveFlowModelOutput: AnyObject {

}

public protocol ImportDictionaryArchiveFlowModel: ImportDictionaryArchiveFlowModelOutput, ImportDictionaryArchiveFlowModelInput {

}
