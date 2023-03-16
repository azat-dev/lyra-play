//
//  ImportDictionaryArchiveFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.01.2023.
//

import Foundation

public final class ImportDictionaryArchiveFlowModelImpl: ImportDictionaryArchiveFlowModel {
    
    // MARK: - Properties
    
    private let url: URL
    private let mainFlowModel: MainFlowModel
    private let importDictionaryArchiveUseCaseFactory: ImportDictionaryArchiveUseCaseFactory
    private weak var delegate: ImportDictionaryArchiveFlowModelDelegate?
    
    // MARK: - Initializers
    
    public init(
        url: URL,
        mainFlowModel: MainFlowModel,
        delegate: ImportDictionaryArchiveFlowModelDelegate,
        importDictionaryArchiveUseCaseFactory: ImportDictionaryArchiveUseCaseFactory
    ) {
        
        self.url = url
        self.mainFlowModel = mainFlowModel
        self.importDictionaryArchiveUseCaseFactory = importDictionaryArchiveUseCaseFactory
        self.delegate = delegate
    }
}

// MARK: - Input Methods

extension ImportDictionaryArchiveFlowModelImpl {
    
    public func start() {

        mainFlowModel.mainTabBarViewModel.selectDictionaryTab()
        
        Task {

            guard
                let dictionaryFlow = await mainFlowModel.dictionaryFlow.values.first(where: { $0 != nil })
            else {
                return
            }
            
            guard let data = try? Data(contentsOf: url) else {
                delegate?.importDictionaryArchiveFlowModelDidDispose()
                return
            }
            
            let importDictionaryArchiveUseCase = self.importDictionaryArchiveUseCaseFactory.make()
            
            let result = await importDictionaryArchiveUseCase.importArchive(data: data)
            
            await dictionaryFlow?.listViewModel.load()
            delegate?.importDictionaryArchiveFlowModelDidDispose()
        }
    }
}
