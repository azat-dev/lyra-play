//
//  EditDictionaryItemViewFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

public protocol EditDictionaryItemViewFactory {

    func make(viewModel: EditDictionaryItemViewModel) -> EditDictionaryItemViewController
}
