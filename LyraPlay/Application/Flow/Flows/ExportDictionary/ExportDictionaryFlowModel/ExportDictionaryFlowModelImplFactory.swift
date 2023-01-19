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
    private let provideFileForSharingUseCaseFactory: ProvideFileForSharingUseCaseFactory
    private let fileSharingViewModelFactory: FileSharingViewModelFactory

    // MARK: - Initializers

    public init(
        exportDictionaryUseCaseFactory: ExportDictionaryUseCaseFactory,
        provideFileForSharingUseCaseFactory: ProvideFileForSharingUseCaseFactory,
        fileSharingViewModelFactory: FileSharingViewModelFactory
    ) {

        self.exportDictionaryUseCaseFactory = exportDictionaryUseCaseFactory
        self.provideFileForSharingUseCaseFactory = provideFileForSharingUseCaseFactory
        self.fileSharingViewModelFactory = fileSharingViewModelFactory
    }

    // MARK: - Methods

    public func create(
        originalText: String?,
        delegate: ExportDictionaryFlowModelDelegate
    ) -> ExportDictionaryFlowModel {

        return ExportDictionaryFlowModelImpl(
            exportDictionaryUseCaseFactory: exportDictionaryUseCaseFactory,
            provideFileForSharingUseCaseFactory: provideFileForSharingUseCaseFactory,
            fileSharingViewModelFactory: fileSharingViewModelFactory,
            delegate: delegate
        )
    }
}
