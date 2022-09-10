//
//  FilesPickerViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.09.2022.
//

import Foundation

public final class FilesPickerViewModelImplFactory: FilesPickerViewModelFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func create(
        documentTypes: [String],
        allowsMultipleSelection: Bool,
        delegate: FilesPickerViewModelDelegate
    ) -> FilesPickerViewModel {

        return FilesPickerViewModelImpl(
            documentTypes: documentTypes,
            allowsMultipleSelection: allowsMultipleSelection,
            delegate: delegate
        )
    }
}
