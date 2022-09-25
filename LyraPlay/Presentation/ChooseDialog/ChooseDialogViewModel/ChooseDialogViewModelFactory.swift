//
//  ChooseDialogViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

public protocol ChooseDialogViewModelFactory {

    func create(
        title: String,
        items: [ChooseDialogViewModelItem],
        delegate: ChooseDialogViewModelDelegate
    ) -> ChooseDialogViewModel
}
