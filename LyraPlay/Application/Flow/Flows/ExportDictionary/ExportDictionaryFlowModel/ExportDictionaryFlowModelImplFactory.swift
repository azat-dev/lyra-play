//
//  ExportDictionaryFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.01.2023.
//

import Foundation

public final class ExportDictionaryFlowModelImplFactory: ExportDictionaryFlowModelFactory {

    // MARK: - Properties

    private let outputFileName: String
    private let provideFileForSharingUseCaseFactory: ProvideFileForSharingUseCaseFactory
    private let fileSharingViewModelFactory: FileSharingViewModelFactory

    // MARK: - Initializers

    public init(
        outputFileName: String,
        provideFileForSharingUseCaseFactory: ProvideFileForSharingUseCaseFactory,
        fileSharingViewModelFactory: FileSharingViewModelFactory
    ) {

        self.outputFileName = outputFileName
        self.provideFileForSharingUseCaseFactory = provideFileForSharingUseCaseFactory
        self.fileSharingViewModelFactory = fileSharingViewModelFactory
    }

    // MARK: - Methods

    public func create(
        delegate: ExportDictionaryFlowModelDelegate
    ) -> ExportDictionaryFlowModel {

        return ExportDictionaryFlowModelImpl(
            outputFileName: outputFileName,
            provideFileForSharingUseCaseFactory: provideFileForSharingUseCaseFactory,
            fileSharingViewModelFactory: fileSharingViewModelFactory,
            delegate: delegate
        )
    }
}
