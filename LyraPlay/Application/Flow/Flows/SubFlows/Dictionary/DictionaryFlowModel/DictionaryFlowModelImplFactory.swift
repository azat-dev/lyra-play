//
//  DictionaryFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation

public final class DictionaryFlowModelImplFactory: DictionaryFlowModelFactory {

    // MARK: - Properties

    private let viewModelFactory: DictionaryListBrowserViewModelFactory
    private let addDictionaryItemFlowModelFactory: AddDictionaryItemFlowModelFactory
    private let deleteDictionaryItemFlowModelFactory: DeleteDictionaryItemFlowModelFactory
    private let exportDictionaryFlowModelFactory: ExportDictionaryFlowModelFactory

    // MARK: - Initializers

    public init(
        viewModelFactory: DictionaryListBrowserViewModelFactory,
        addDictionaryItemFlowModelFactory: AddDictionaryItemFlowModelFactory,
        deleteDictionaryItemFlowModelFactory: DeleteDictionaryItemFlowModelFactory,
        exportDictionaryFlowModelFactory: ExportDictionaryFlowModelFactory
    ) {

        self.viewModelFactory = viewModelFactory
        self.addDictionaryItemFlowModelFactory = addDictionaryItemFlowModelFactory
        self.deleteDictionaryItemFlowModelFactory = deleteDictionaryItemFlowModelFactory
        self.exportDictionaryFlowModelFactory = exportDictionaryFlowModelFactory
    }

    // MARK: - Methods

    public func make() -> DictionaryFlowModel {

        return DictionaryFlowModelImpl(
            viewModelFactory: viewModelFactory,
            addDictionaryItemFlowModelFactory: addDictionaryItemFlowModelFactory,
            deleteDictionaryItemFlowModelFactory: deleteDictionaryItemFlowModelFactory,
            exportDictionaryFlowModelFactory: exportDictionaryFlowModelFactory
        )
    }
}
