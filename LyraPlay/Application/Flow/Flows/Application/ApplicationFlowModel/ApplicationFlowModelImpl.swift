//
//  ApplicationFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.01.2023.
//

import Foundation
import Combine

public final class ApplicationFlowModelImpl: ApplicationFlowModel {

    // MARK: - Properties

    public let mainFlowModel: MainFlowModel
    private let importDictionaryArchiveFlowModelFactory: ImportDictionaryArchiveFlowModelFactory
    
    public let importDictionaryArchiveFlowModel = CurrentValueSubject<ImportDictionaryArchiveFlowModel?, Never>(nil)
    
    // MARK: - Initializers

    public init(
        mainFlowModel: MainFlowModel,
        importDictionaryArchiveFlowModelFactory: ImportDictionaryArchiveFlowModelFactory
    ) {
        
        self.mainFlowModel = mainFlowModel
        self.importDictionaryArchiveFlowModelFactory = importDictionaryArchiveFlowModelFactory
    }
}

// MARK: - Input Methods

extension ApplicationFlowModelImpl {

    public func runImportDictionaryArchiveFlow(url: URL) {
        
        if importDictionaryArchiveFlowModel.value != nil {
            return
        }
        
        let importDictionaryArchiveFlowModel = importDictionaryArchiveFlowModelFactory.create(
            url: url,
            mainFlowModel: mainFlowModel,
            delegate: self
        )
        
        self.importDictionaryArchiveFlowModel.value = importDictionaryArchiveFlowModel
        importDictionaryArchiveFlowModel.start()
    }
}

// MARK: -  ImportDictionaryArchiveFlowModelDelegate

extension ApplicationFlowModelImpl: ImportDictionaryArchiveFlowModelDelegate {

    public func importDictionaryArchiveFlowModelDidDispose() {
        
        importDictionaryArchiveFlowModel.value = nil
    }
}
