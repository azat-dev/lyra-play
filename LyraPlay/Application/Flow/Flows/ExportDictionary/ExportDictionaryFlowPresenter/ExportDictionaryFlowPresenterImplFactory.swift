//
//  ExportDictionaryFlowPresenterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.01.2023.
//

import Foundation

public final class ExportDictionaryFlowPresenterImplFactory: ExportDictionaryFlowPresenterFactory {

    // MARK: - Properties

    private let fileSharingViewControllerFactory: FileSharingViewControllerFactory

    // MARK: - Initializers

    public init(fileSharingViewControllerFactory: FileSharingViewControllerFactory) {

        self.fileSharingViewControllerFactory = fileSharingViewControllerFactory
    }

    // MARK: - Methods

    public func create(for flowModel: ExportDictionaryFlowModel) -> ExportDictionaryFlowPresenter {

        return ExportDictionaryFlowPresenterImpl(
            flowModel: flowModel,
            fileSharingViewControllerFactory: fileSharingViewControllerFactory
        )
    }
}