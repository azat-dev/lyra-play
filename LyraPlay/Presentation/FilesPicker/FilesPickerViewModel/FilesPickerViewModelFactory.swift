//
//  FilesPickerViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.09.2022.
//

public protocol FilesPickerViewModelFactory {

    func create(
        documentTypes: [String],
        allowsMultipleSelection: Bool,
        delegate: FilesPickerViewModelDelegate
    ) -> FilesPickerViewModel
}
