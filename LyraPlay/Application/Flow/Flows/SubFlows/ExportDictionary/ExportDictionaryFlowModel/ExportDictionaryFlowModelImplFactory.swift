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
    private let fileSharingViewModelFactory: FileSharingViewModelFactory

    // MARK: - Initializers

    public init(
        outputFileName: String,
        fileSharingViewModelFactory: FileSharingViewModelFactory
    ) {

        self.outputFileName = outputFileName
        self.fileSharingViewModelFactory = fileSharingViewModelFactory
    }

    // MARK: - Methods

    public func create(
        delegate: ExportDictionaryFlowModelDelegate
    ) -> ExportDictionaryFlowModel {

        return ExportDictionaryFlowModelImpl(
            outputFileName: outputFileName,
            fileSharingViewModelFactory: fileSharingViewModelFactory,
            delegate: delegate
        )
    }
}
