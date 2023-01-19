//
//  ExportDictionaryFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.01.2023.
//

import Foundation

public final class ExportDictionaryFlowModelImplFactory: ExportDictionaryFlowModelFactory {

    // MARK: - Properties

    private let exportDictionaryUseCaseFactory: ExportDictionaryUseCaseFactory
    private let provideFileUrlUseCaseFactory: ProvideFileUrlUseCaseFactory
    private let fileSharingViewModelFactory: FileSharingViewModelFactory

    // MARK: - Initializers

    public init(
        exportDictionaryUseCaseFactory: ExportDictionaryUseCaseFactory,
        provideFileUrlUseCaseFactory: ProvideFileUrlUseCaseFactory,
        fileSharingViewModelFactory: FileSharingViewModelFactory
    ) {

        self.exportDictionaryUseCaseFactory = exportDictionaryUseCaseFactory
        self.provideFileUrlUseCaseFactory = provideFileUrlUseCaseFactory
        self.fileSharingViewModelFactory = fileSharingViewModelFactory
    }

    // MARK: - Methods

    public func create(
        originalText: String?,
        delegate: ExportDictionaryFlowModelDelegate
    ) -> ExportDictionaryFlowModel {

        return ExportDictionaryFlowModelImpl(
            exportDictionaryUseCaseFactory: exportDictionaryUseCaseFactory,
            provideFileUrlUseCaseFactory: provideFileUrlUseCaseFactory,
            fileSharingViewModelFactory: fileSharingViewModelFactory,
            delegate: delegate
        )
    }
}