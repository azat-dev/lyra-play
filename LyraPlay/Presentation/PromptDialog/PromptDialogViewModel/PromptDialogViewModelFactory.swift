//
//  PromptDialogViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

public protocol PromptDialogViewModelFactory {

    func create(
        messageText: String,
        submitText: String,
        cancelText: String,
        delegate: PromptDialogViewModelDelegate
    ) -> PromptDialogViewModel
}