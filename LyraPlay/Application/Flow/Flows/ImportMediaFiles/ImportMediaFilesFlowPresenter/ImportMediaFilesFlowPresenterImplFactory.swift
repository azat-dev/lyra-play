//
//  ImportMediaFilesFlowPresenterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation

public final class ImportMediaFilesFlowPresenterImplFactory: ImportMediaFilesFlowPresenterFactory {

    // MARK: - Properties

    private let filesPickerViewFactory: FilesPickerViewFactory

    // MARK: - Initializers

    public init(filesPickerViewFactory: FilesPickerViewFactory) {

        self.filesPickerViewFactory = filesPickerViewFactory
    }

    // MARK: - Methods

    public func create(for flowModel: ImportMediaFilesFlowModel) -> ImportMediaFilesFlowPresenter {

        return ImportMediaFilesFlowPresenterImpl(
            flowModel: flowModel,
            filesPickerViewFactory: filesPickerViewFactory
        )
    }
}
