//
//  EditDictionaryItemViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

public protocol EditDictionaryItemViewModelFactory {

    func make(
        with params: EditDictionaryItemParams,
        delegate: EditDictionaryItemViewModelDelegate
    ) -> EditDictionaryItemViewModel
}
