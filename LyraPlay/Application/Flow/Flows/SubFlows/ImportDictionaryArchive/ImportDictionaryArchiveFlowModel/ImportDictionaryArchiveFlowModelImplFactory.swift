//
//  ImportDictionaryArchiveFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.01.2023.
//

import Foundation

public final class ImportDictionaryArchiveFlowModelImplFactory: ImportDictionaryArchiveFlowModelFactory {
    
    // MARK: - Properties
    
    private let importDictionaryArchiveUseCaseFactory: ImportDictionaryArchiveUseCaseFactory
    
    // MARK: - Initializers
    
    public init(
        importDictionaryArchiveUseCaseFactory: ImportDictionaryArchiveUseCaseFactory
    ) {
        
        self.importDictionaryArchiveUseCaseFactory = importDictionaryArchiveUseCaseFactory
    }
    
    // MARK: - Methods
    
    public func make(
        url: URL,
        mainFlowModel: MainFlowModel,
        delegate: ImportDictionaryArchiveFlowModelDelegate
    ) -> ImportDictionaryArchiveFlowModel {
        
        return ImportDictionaryArchiveFlowModelImpl(
            url: url,
            mainFlowModel: mainFlowModel,
            delegate: delegate,
            importDictionaryArchiveUseCaseFactory: importDictionaryArchiveUseCaseFactory
        )
    }
}
